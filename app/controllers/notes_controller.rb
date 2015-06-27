class NotesController < ApplicationController
 
  def index
    @notes = Note.recent_notes
    @note = Note.new
  end

  def show
    @note = Note.find_by_id(params[:id])
  end

  def create
    
    note = Note.new(get_user_params)
    if note.save
      # Extract tags
      tags = get_tags
      unless tags.empty?
        #save tags
        save_tags(tags,note)
      end
      flash[:success]="Note added."
      redirect_to(notes_path)
    else
      flash[:error]="Error occured while saving note.. !"
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
        note.tags.each do |tag|
          tag.destroy
          puts " >>> Tag #{tag.tagname} Destroyed .. "
        end
        #save tags
        save_tags(tags,note)
      end
      flash[:success]="Note updated."
      redirect_to(notes_path)
    else
      flash[:error]="Error occured while updating note.. !"
      @note = Note.find_by_id(params[:id])
      render(edit_note_path(params[:id]))
    end
  end

  def destroy
    note = Note.find_by_id(params[:id])
    note.destroy
    flash[:success]="Note disposed."
    redirect_to(notes_path)
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
    return tags
  end

  def save_tags(tags,note)
    tags.each do |tag|
      new_tag = Tag.new(:tagname=>tag)
      note.tags << new_tag
      puts ">>> Tags added are : #{tag}"
    end
  end
end
