class NotesController < ApplicationController
  layout 'application' 
  
  before_action :check_logged_in,:get_notifications
  #check for privileges before updation of note
  before_action :check_user_privileges,:only=>[:update]

  def index
    user = User.find_by_id(session[:id])
    @note = Note.new
    #If tags are searched
    if(params[:search_by])
      # find tag
      tag = user.tags.find_by_tagname(params[:search_by])
      #Find notes related to this tag
      @notes = tag.notes.recent_notes
    else
      # No search 
      @notes = user.notes.recent_notes
    end
    
    # User's most frequently used tags
    @tags = get_suggested_tags

  end

  def show
    @note = Note.find_by_id(params[:id])
  end

  def create
    user = User.find_by_id(session[:id])
    note = Note.new(get_user_params)
    if note.save
      # Extract tags
      tags = get_tags(nil)
      unless tags.empty?
        #save tags
        save_tags([user],tags,note)
      end
      # === OLD CODE === #
      #Extract collab Users
      # collab_users = get_users(nil)
      # unless collab_users.empty?
      #   #save it to shared users
      #   save_collab_users(collab_users,note)
      # end
      # add the admin to user, but genereate notifications for users other than admin
      Collaboration.create(:user=>user,:note=>note,:is_admin=>true)
      # === Modified above collaboration to integrate Notifications === #
      users = get_users(nil)
      generate_notifications(users,note) unless users.empty?

      flash[:notice]="Note added."
      redirect_to(user_notes_path(session[:id]))
    else
      flash[:alert]="Error occured while saving note.. !"
      redirect_to(user_notes_path(session[:id]))
    end
    
  end

  def edit
    @note = Note.find_by_id(params[:id])
  end

  def update
    note = Note.find_by_id(params[:id])
    user = User.find_by_id(session[:id])

    if note.update_attributes(get_user_params)
      #updating the collab users as well as tags
      if check_if_admin
        #if admin also update the collab users
        users = get_users(nil)
        update_collab_users(users,note)
      end
      flash[:notice]="Note updated."
      redirect_to(user_notes_path(session[:id]))

      #Update the tags to all the users that are collaborated
      # Extract tags
      tags = get_tags(nil)
      unless tags.empty?
        #remove previous tags of this note
        #all users that are currently collabored with this note
        c_users = note.users

        tags.each do |tag|
          if my_tag = user.tags.find_by_tagname(tag)
            # if tag already there then touch it (for recommendation purpose)
            my_tag.touch
          else 
            #not present so save it 
            save_tags(c_users,tags,note)
          end
        end
      end
    else
      flash[:alert]="Error occured while updating note.. !"
      @note = Note.find_by_id(params[:id])
      render('edit')
    end
  end

  def destroy
    note = Note.find_by_id(params[:id])
    note.destroy
    flash[:notice]="Note disposed."
    redirect_to(user_notes_path(session[:id]))
  end


  def accept_notification
    notification = Notification.find_by_id(params[:notification_id])
    # mark notification as seen
    notification.is_seen = true
    notification.save
    note = notification.note
    admin = User.find_by_username(notification.from_user) 
    c_user = notification.user
    Collaboration.create(:user=>c_user,:note=>note,:is_admin=>false) if c_user
    
    #Save tags of this note for our user
    tags = get_tags(note.content)
    unless tags.empty?
      #save tags
      save_tags([c_user],tags,note)
    end

    flash[:notice]="You are in collaboration with @#{admin.username}"
    redirect_to user_notes_path(session[:id])
  end

  def reject_notification
    notification = Notification.find_by_id(params[:notification_id])
    notification.is_seen = true
    notification.save

    #notify the admin user that the person rejected the collaboration request
    admin = User.find_by_username(notification.from_user)
    note = notification.note
    Notification.create(:user=>admin,:from_user=>session[:username],:note=>note,:rejected=>true)

    redirect_to user_notes_path(session[:id]) 
  end


# PRIVATE FUNCTIONS
  private

  def get_user_params
    params.require(:note).permit(:content)
  end

  def get_tags(content)
    content ||= params[:note][:content]
    tags_with_junk = content.split("#")
    tags_with_junk.shift
    #remove spaces 
    tags = []
    tags_with_junk.each do |junk_tags| 
      tags << junk_tags.split(" ")[0]
    end
    #return unique tags only
    return tags.uniq
  end

  def save_tags(users,tags,note)
    users.each do |user|
      tags.each do |tag|
        # Find if tag already exist
        result = user.tags.find_by_tagname(tag)
        if result.nil?
          #new tag so add it for that note
          new_tag = Tag.new(:tagname=>tag)
          user.tags << new_tag
        else
          # give new_tag the already existed tag 
          if old_tag = note.tags.find_by_tagname(tag)
            # if it was attached to note already
            old_tag.touch
          else
            # save the result to attach to note
            new_tag = result
          end
        end

        note.tags << new_tag if new_tag
      end


    end
  end

  def get_users(content)
    content||=params[:note][:content]
    users_with_junk = content.split("@")
    users_with_junk.shift
    #remove spaces 
    users = []
    users_with_junk.each do |junk_user| 
      users << junk_user.split(" ")[0]
    end
    #make sure it's downcased
    users.each do |user|
      user.downcase!
    end
    #remove users name .. if they put it by default
    return users
  end

  def generate_notifications(users,note)
    users.each do |username|
      user = User.find_by_username(username)
      Notification.create(:user=>user,:note=>note,:is_seen=>false,:from_user=>session[:username])
    end
  end

  def update_collab_users(users,note)
    old_users = []
    note.collaborations.each do |collab|
      old_users<<collab.user.username
    end
    old_users= old_users - [session[:username]]

    new_users = users-old_users
    delete_users = old_users - users

    unless new_users.empty?
      new_users.each do |username|
        # #if not already there add it
        # c_user = User.find_by_username(username)
        # Collaboration.create(:user=>c_user,:note=>note,:is_admin=>false) if c_user
        # === GENERATE NOTIFICATION IF ANY NEW USER === 
        user = User.find_by_username(username)
        Notification.create(:user=>user,:note=>note,:from_user=>session[:username])
      end
    end
    unless delete_users.empty?
      #delete removed users by admin
      note.collaborations.each do |collab|
        if delete_users.find(){|name| name==collab.user.username}
          collab.destroy
          # get user notified about removal
          Notification.create(:user=>collab.user,:note=>note,:is_removed=>true,:from_user=>session[:username])
        end
      end
    end
  end

  def get_suggested_tags
    # note: Tags are already unique 
    # tagnames with most occurences first
    user = User.find_by_id(session[:id])
    tagnames = {}
    #tagname = {tagname,occurence}
    tags = user.tags.recent_tags
    tags.each do |tag|
       tagnames[tag.tagname]=tag.notes.count
    end
    puts ">>>> #{tags.inspect} "
    #Sort in most occurence first & returned multi dim array
    tagnames.sort{|val1, val2| val2[1]<=>val1[1]}
  end

  def check_user_privileges
    note = Note.find_by_id(params[:id])
    #old one's
    set1 = get_users(nil)
    #after updating note
    set2 = get_users(note.content)

    if (set1-set2).empty? && (set2-set1).empty?
      #No updation of collab users
      return true
    else
      # there is an updation of collab users in the note
      #if admin of this note => All ohk
      if check_if_admin 
        return true
      else
        flash[:warning]="You don't have permission to modify collaborated users !"
        @note = note
        render('edit')
        return false   
      end
    end
  end

  def get_notifications
    user = User.find_by_id(session[:id])
    @notifications = user.notifications
  end
end
