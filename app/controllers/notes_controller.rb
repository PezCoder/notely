class NotesController < ApplicationController
  layout 'application' 
  
  before_action :check_logged_in

  def index
    user = User.find_by_id(session[:id])
    @note = Note.new
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
      tags = get_tags
      unless tags.empty?
        #save tags
        save_tags(tags,note)
      end
      #Extract User
      collab_users = get_users
      unless collab_users.empty?
        #save it to shared users
        save_collab_users(collab_users,note)
      end
      # add it to user
      user.notes << note
      
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
      tags = get_tags
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

  def get_tags
    content = params[:note][:content]
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

  def get_users
    content = params[:note][:content]
    users_with_junk = content.split("@")
    users_with_junk.shift
    #remove spaces 
    users = []
    users_with_junk.each do |junk_user| 
      users << junk_user.split(" ")[0]
    end
    return users
  end

  def save_collab_users(users,note)
    users.each do |username|
      new_user = SharedUser.new(:username=>username)
      note.shared_users << new_user
      puts ">>> Tags added are : #{tag}"
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

end
