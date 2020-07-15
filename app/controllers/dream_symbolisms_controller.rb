class DreamSymbolismsController < ApplicationController
    before_action :require_login, only: [:new, :create, :edit, :update, :destroy]
    before_action :set_dream_symbolism, only: [:edit, :update, :destroy]
    before_action :check_user, only: [:edit, :update, :destroy]

    def new
        @dream = Dream.find_by(id: params[:dream_id])
        @num = params[:number].to_i
    end

    def create
        @dream = Dream.find_by(id: params[:dream_id])
        
        dream_symbolism_attrs = params.require(:dream_symbolisms).permit(instances: [:symbolism_id, :meaning, :dream_id, symbolism_attributes: [:name]]).fetch(:instances)
        dream_symbolism_attrs.each do |ds_attr|
            @dream_symbolism = DreamSymbolism.create(ds_attr)
            flash[:error] = @dream_symbolism.errors.full_messages if @dream_symbolism.errors.any?
        end
        redirect_to user_dream_path(@dream.user, @dream)
    end

    def edit
    end

    def update
        if @dream_symbolism.update(dream_symbolism_params(:meaning, :symbolism_id, symbolism_attributes: [:name]))
            redirect_to user_dream_path(current_user, @dream_symbolism.dream)
        else
            render 'edit'
        end
    end

    def destroy
        dream = @dream_symbolism.dream
        @dream_symbolism.destroy
        redirect_to user_dream_path(current_user, dream )
    end

    private

    def set_dream_symbolism
        @dream_symbolism = DreamSymbolism.find_by(id: params[:id])
    end
    
    def dream_symbolism_params(*args)
        params.require(:dream_symbolism).permit(*args)
    end

    def check_user
        unless current_user == @dream_symbolism.dream.user
            flash[:error] = "Invalid Input"
            redirect_to root_path
        end
    end
end