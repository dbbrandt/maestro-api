module Api
  class ContentsController < ApplicationController
    before_action :set_interaction

    # GET /interactions/:interaction_id/contents
    def index
      json_response(@interaction.contents)
    end

    # GET /interactions/:interaction_id/contents/:id
    def show
      set_interaction_content
      return json_response("Couldn't find Content", :not_found) unless @content
      json_response(@content, status)
    end

    # POST /interactions/:interaction_id/contents
    def create
      @content = @interaction.contents.create!(content_params)
      return json_response("Couldn't find Content", :not_found) unless @content
      json_response(@content, :created)
    end

    # PUT /interactions/:interaction_id/contents/:id
    def update
      set_interaction_content
      return json_response("Couldn't find Content", :not_found) unless @content
      @content.update(content_params)
      head :no_content
    end

    # DELETE /interactions/:interation_id/contents/:id
    def destroy
      set_interaction_content
      return json_response("Couldn't find Content", :not_found) unless @content
      @content.destroy
      head :no_content
    end

    private

    def content_params
      params.permit(:title, :content_type, :description, :copy, :score, :descriptor)
    end

    def set_interaction
      @interaction = Interaction.preload(:contents).find(params[:interaction_id])
    end

    def set_interaction_content
      @content = @interaction.contents.find { |c| c.id == params[:id].to_i} if @interaction
    end
  end
end
