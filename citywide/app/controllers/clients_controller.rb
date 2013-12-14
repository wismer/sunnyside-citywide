class ClientsController < ApplicationController
  def index
    @clients = Client.all
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(post_params)
    @client.save
    redirect_to @client
  end

  def destroy
  end

  def show
    @client = Client.find(params[:id])
  end

  private
    def post_params
      params.require(:client).permit(:name, :fund_id)
    end
end
