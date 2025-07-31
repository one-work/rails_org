module Org
  class My::AuthorizedTokensController < My::BaseController
    before_action :set_authorized_token, only: [:update]

    def update
      @authorized_token.assign_attributes(authorized_token_params)

      if @authorized_token.save
        if @authorized_token.member
          url = url_for(controller: '/our/home', **params.permit(:org_id))
        else
          url = url_for(controller: '/my/home', **params.permit(:org_id))
        end
        render :update, locals: { url: params[:return_url].presence || url }
      else
        render :update, locals: { url: url_for(controller: 'trade/my/carts', action: 'list') }
      end
    end

    private
    def set_authorized_token
      @authorized_token = Current.session
    end

    def authorized_token_params
      params.permit(:member_id)
    end
  end
end
