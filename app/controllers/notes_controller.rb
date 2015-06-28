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
      flash[:notice]="Note added."
      redirect_to(notes_path)
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
      flash[:notice]="Note updated."
      redirect_to(notes_path)
    else
      flash[:alert]="Error occured while updating note.. !"
      @note = Note.find_by_id(params[:id])
      render(edit_note_path(params[:id]))
    end
  end

  def destroy
    note = Note.find_by_id(params[:id])
    note.destroy
    flash[:notice]="Note disposed."
    redirect_to(notes_path)
  end

  private

  def get_user_params
    params.require(:note).permit(:content)
  end
end
