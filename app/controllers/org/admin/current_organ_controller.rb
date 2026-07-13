module Org
  class Admin::CurrentOrganController < Admin::BaseController

    def update
      current_organ.assign_attributes(organ_params)

      if current_organ.save
        render 'update'
      else
        render :edit
      end
    end

    def destroy
      current_organ.destroy
    end

    private
    def organ_params
      params.fetch(:organ, {}).permit(
        :name,
        :logo,
        :name_short,
        :parent_ancestors,
        :area_ancestors
      )
    end

    def organ_limit_params
      params.fetch(:organ, {}).permit(
        :limit_office,
        :limit_wechat
      )
    end

  end
end
