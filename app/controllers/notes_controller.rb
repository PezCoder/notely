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
end
