class NotesController < ApplicationController
  layout 'application' 
  
  before_action :check_logged_in,:get_notifications
  #check for privileges before updation of note
  before_action :check_user_privileges,:only=>[:update]

  def index
    user = User.find_by_id(session[:id])
    @note = Note.new
    # User's most frequently used tags & users
    @tags = get_suggested_tags
    @users = get_suggested_users
    #If tags are filtered
    if(params[:filter_tagname])
      #Find notes related to this tag
      @notes = notes_by_tagnames([params[:filter_tagname]])
    elsif params[:filter_user]
      @notes = []
      user.notes.each do |note|
        note.users.each do |cuser|
          if cuser.username == params[:filter_user]
            @notes << note
          end
        end
      end
    elsif params[:search]
      #right search bar that searches for tags
      unless params[:search].strip==""
        #get all tags that contains this searched tagname
        @tags = get_suggested_tags(params[:search])
        #get all notes of all each of those tags
        @notes = notes_by_tagnames(@tags)
      else
        @notes = user.notes.recent_notes
      end
    else
      # No search 
      @notes = user.notes.recent_notes
    end
    respond_to :html,:js
  end

  def show
    @note = Note.find_by_id(params[:id])
  end

  def create
    user = User.find_by_id(session[:id])
    @note = Note.new(get_user_params)
    if @note.save
      # Extract tags
      tags = get_tags(nil)
      unless tags.empty?
        #save tags
        save_tags([user],tags,@note)
      end

      Collaboration.create(:user=>user,:note=>@note,:is_admin=>true)
      # === Modified above collaboration to integrate Notifications === #
      users = get_users(nil)
      generate_notifications(users,@note) unless users.empty?
      flash[:notice]="Note added."
      # User's most frequently used tags
      @tags = get_suggested_tags
      @users = get_suggested_users
      respond_to do |format|
        format.html { redirect_to(user_notes_path(session[:id])) }
        format.js
      end
    else
      flash[:alert]="Error occured while saving note.. !"
      redirect_to(user_notes_path(session[:id]))
    end
    
  end

  def edit
    @note = Note.find_by_id(params[:id])
    respond_to :html,:js
  end

  def update
    @note = Note.find_by_id(params[:id])
    user = User.find_by_id(session[:id])

    if @note.update_attributes(get_user_params)
      #updating the collab users as well as tags
      if check_if_admin
        #if admin also update the collab users
        users = get_users(nil)
        update_collab_users(users,@note)
      end
      #Update the tags to all the users that are collaborated
      # Extract tags
      tags = get_tags(nil)
      #delete tags that are not present after updation
      update_tags(@note,tags)

      # @tags for updating the tags on the fly
      @tags = get_suggested_tags
      flash[:notice]="Note updated."
      # Hanlde ajax request
      respond_to do |format|
        format.html{ redirect_to(user_notes_path(session[:id])) }
        format.js
      end  
      
    else
      flash[:alert]="Error occured while updating note.. !"
      @note = Note.find_by_id(params[:id])
      #proper redirection acc to ajax request
      respond_to do |format|
        format.html{ render('edit') }
        format.js
      end
      
    end

  end

  def destroy
    @note = Note.find_by_id(params[:id])
    @note.destroy
    flash[:notice]="Note disposed."
    # update new tags & users with ajax 
    @tags = get_suggested_tags
    @users = get_suggested_users
    respond_to do |format|
      format.html { redirect_to(user_notes_path(session[:id])) }
      format.js
    end

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

  def suggest_tags
    #get the tags starting with this
    #true is the only_starts_with parameter so it only filters the one's that starts with the sent substr
    @tags = get_suggested_tags(params[:tagname],true)
    respond_to :js
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
          #Since we want Tag table to be unique so find if there is any tagname there else create new one
          new_tag = Tag.find_by_tagname(tag) || Tag.new(:tagname=>tag)
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
        TagsHandler.create(:user=>user,:note=>note,:tag=>new_tag) if new_tag
      end #end tags
    end #end users

  end

  def update_tags(note,tags)
    user = User.find_by_id(session[:id])
    handlers = TagsHandler.where(:note=>note,:user=>user)
    #delete tags that are not present after updation
    old_tags = []
    note.tags.each do |tag|
      old_tags<<tag.tagname
    end
    new_tags = tags
    #add the new tags
    add_tags = new_tags-old_tags
    unless add_tags.empty?
      c_users = note.users
      save_tags(c_users,add_tags,note)
    end

    #don't forget to touch old tags handlers for better recommendations :)
    old_tags.each do |old_tag|
      #update all those user-note-tags relationship
      handlers.each do |handler|
        puts(">>> Old Tag " + old_tag);
        puts(">>> Handler\n #{handler}");
        handler.touch if handler.tag.tagname==old_tag
      end
    end
    
    #destroy whatever tags are not present now
    delete_tags = old_tags - new_tags
    unless delete_tags.empty?
      delete_tags.each do |tagname| 
        #find tags associated with that note (don't use note.tags)
        handlers.each do |handler|
          handler.destroy if handler.tag.tagname==tagname
        end
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

  def get_suggested_tags(search_tagname=nil,only_starting_with=false)
    # note: Tags are already unique 
    # tagnames with most occurences first
    user = User.find_by_id(session[:id])
    tagnames = {}
    #tagname = {tagname,occurence}
    puts user.tags.inspect
    tags = []
    handlers = TagsHandler.where(:user=>user).recent_handlers
    handlers.each do |handler|
      tags << handler.tag
    end
    tags.each do |tag|
      puts "#{tag.notes.inspect}"
      #count that user's tag's notes.. 
      if search_tagname
        #only_starting_with is for returning the one's that just starts with the tagname passed
        if only_starting_with 
          if search_tagname.strip=="" || check_if_starts_with(tag.tagname.downcase,search_tagname.downcase)
            tagnames[tag.tagname]=TagsHandler.where(:user=>user,:tag=>tag).count 
          end
        else
          #all the tagnames that contains the tagname passed
          if search_tagname.strip=="" || tag.tagname.downcase.include?(search_tagname.downcase) 
            tagnames[tag.tagname]=TagsHandler.where(:user=>user,:tag=>tag).count 
          end
        end
      else 
        tagnames[tag.tagname]=TagsHandler.where(:user=>user,:tag=>tag).count 
      end

    end
    #Sort in most occurence first & returned multi dim array
    return tagnames.sort{|val1, val2| val2[1]<=>val1[1]}
  end

  def check_if_starts_with(str,substr)
    #helper function for the above get_suggested_tag function
    # return true if str contains substr & starts with it
    substr.length.times do |i|
      if str[i]!=substr[i]
        return false
      end
    end
    return true
  end

  def get_suggested_users
    user = User.find_by_id(session[:id])
    notes = user.notes.recent_notes
    usernames = {}
    notes.each do |note|
      note.users.each do |user|
        if usernames.find(){|username| username==user.username}
          #if found increment count
          usernames[user.username]+=1
        else 
          # initialize to 0
          usernames[user.username]=1
        end    
      end
    end
    usernames.delete(user.username)
    puts " >>> Users COllaborated " + usernames.inspect
    #sort acc to values
    return usernames.sort{|val1,val2| val1[1]<=>val2[1]}
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
        respond_to do |format|
          #if html request then load the edit page
          format.html { render('edit') }
          #update the flash to display permission error
          format.js { render('update_flash')}
        end
        return false   
      end
    end
  end

  def notes_by_tagnames(tagnames)
    user = User.find_by_id(session[:id])
    #tagnames is a hash {nameoftag => countOfNotes}
    if(tagnames.empty?)
      return []
    end
    notes = []
    #to not show any copies of same notes
    note_ids = []
    tagnames.each do |tagname|
      # find tag object
      if tagname.class == "Array"
        #then it's a hash so search operation
        tag = user.tags.find_by_tagname(tagname[0])
      else
        #it's a string so we are filtering here :)
        tag = user.tags.find_by_tagname(tagname)  
      end
      handlers = TagsHandler.where(:user=>user,:tag=>tag).recent_handlers
      handlers.each do |handler|
        note = handler.note
        unless note_ids.find(){|id| id==note.id}
          #if note not already found
          notes << handler.note
          note_ids << note.id
        end
      end
    end
    return notes
  end

  # def filter_by_tagname(user,tagname)
  #   tag = user.tags.find_by_tagname(tagname)
  #     handlers = TagsHandler.where(:user=>user,:tag=>tag).recent_handlers
  #     handlers.each do |handler|
  #       note = handler.note
  #       unless note_ids.find(){|id| id==note.id}
  #         #if note not already found
  #         notes << handler.note
  #         note_ids << note.id
  #       end
  #     end
  # end
end
