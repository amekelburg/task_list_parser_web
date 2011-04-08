class ListsController < ApplicationController


  def index
    @list = List.last
    @list ||= List.new    
  end


  def create
    @list = List.create(params[:list])
    render :partial=>"view"
  end
  def update
    @list = List.create(params[:list])    
    render :partial=>"view"
  end

end
