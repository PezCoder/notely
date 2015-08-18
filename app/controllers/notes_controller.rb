class NotesController < ApplicationController
  layout 'application' 
  
  before_action :check_logged_in
  #check for privileges before updation of note
  before_action :check_user_privileges,:only=>[:update]

  def index
    user = User.find_by_id(session[:id])
    @note = Note.new
    #If tags are searched
    if(params[:search_by])
      # find tag
      tag = Tag.find_by_tagname(params[:search_by])
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
        save_tags(tags,note)
      end
      #Extract collab Users
      collab_users = get_users(nil)
      unless collab_users.empty?
        #save it to shared users
        save_collab_users(collab_users,note)
      end
      # add the admin to user
      Collaboration.create(:user=>user,:note=>note,:is_admin=>true)
      
      flash[:notice]="Note added."
      redirect_to(user_notes_path(session[:id]))
    else
      flash[:alert]="Error occured while saving note.. !"
      @note = note
      @notes = Note.recent_notes
      render('index')
    end
  end

  def edit
    @note = Note.find_by_id(params[:id])
  end

  def update
    note = Note.find_by_id(params[:id])
    if note.update_attributes(get_user_params)
      # Extract tags
      tags = get_tags(nil)
      unless tags.empty?
        #remove previous tags of this note
        tags.each do |tag|
          if my_tag = Tag.find_by_tagname(tag)
            # if tag already there then update it
            my_tag.touch
          else 
            #not present so save it 
            save_tags([tag],note)
          end
        end
      end

      #updating the collab users
      if check_if_admin
        #if admin also update the collab users
        users = get_users(nil)
        update_collab_users(users,note)
      end
      flash[:notice]="Note updated."
      redirect_to(user_notes_path(session[:id]))
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

  def save_tags(tags,note)
    tags.each do |tag|
      # Find if tag already exist
      result = Tag.find_by_tagname(tag)
      if result.nil?
        #new tag so add it for that note
        new_tag = Tag.new(:tagname=>tag)
      else
        # give new_tag the already existed tag 
        # This is to ensure we can do tag.notes later on
        new_tag = result
      end

      note.tags << new_tag
      puts ">>> Tags added are : #{tag}"
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
      puts ">> Get User :: #{user}"
    end
    #remove users name .. if they put it by default
    return users
  end

  def save_collab_users(users,note)
    users.each do |username|
      #add collab users with not giving them admin rights
      c_user = User.find_by_username(username)
      Collaboration.create(:user=>c_user,:note=>note,:is_admin=>false) if c_user
    end
  end

  def update_collab_users(users,note)
    old_users = []
    note.collaborations.each do |collab|
      old_users<<collab.user.username
    end
    old_users= old_users - [session[:username]]
    puts ">>> Old Users: " + old_users.inspect

    new_users = users-old_users
    delete_users = old_users - users

    puts ">>> New Users:" + new_users.inspect
    unless new_users.empty?
      new_users.each do |username|
        #if not already there add it
        c_user = User.find_by_username(username)
        puts ">> Added Users : #{username}"
        Collaboration.create(:user=>c_user,:note=>note,:is_admin=>false) if c_user
      end
    end
    puts ">>> Delete Users: #{delete_users.inspect}"
    unless delete_users.empty?
      #delete removed users by admin
      note.collaborations.each do |collab|
        if delete_users.find(){|name| name==collab.user.username}
          puts ">>> Deleted User > #{collab.user.username}" 
          collab.destroy
        end
      end
    end
  end

  def get_suggested_tags
  # note: Tags are already unique since it's accessed from "tags" table
  # tagnames with most occurences first
    tagnames = {}
    #tagname = {tagname,occurence}
    tags = Tag.recent_tags
    tags.each do |tag|
       tagnames[tag.tagname]=tag.notes.count
    end
    #Sort in most occurence first & returned multi dim array
    tagnames.sort{|val1, val2| val2[1]<=>val1[1]}
  end

  def check_user_privileges
    note = Note.find_by_id(params[:id])
    #old one's
    set1 = get_users(nil)
    #after updating note
    set2 = get_users(note.content)
    puts "-----------------"
    puts set1.inspect 
    puts "---------------"
    puts set2.inspect
    puts "---------------"
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


end
