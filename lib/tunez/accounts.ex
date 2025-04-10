defmodule Tunez.Accounts do
  use Ash.Domain, otp_app: :tunez, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  graphql do
    queries do
      get Tunez.Accounts.User, :sign_in_with_password, :sign_in_with_password do
        identity false
        type_name :user_with_token
      end
    end

    mutations do
      create Tunez.Accounts.User, :register_with_password, :register_with_password
    end
  end

  json_api do
    routes do
      base_route "/users", Tunez.Accounts.User do
        post :register_with_password do
          route "/register"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end

        post :sign_in_with_password do
          route "/sign_in"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end
      end
    end
  end

  resources do
    resource Tunez.Accounts.Token

    resource Tunez.Accounts.User do
      define :set_user_role, action: :set_role, args: [:role]
      define :get_user_by_id, action: :read, get_by: [:id]
      define :get_user_by_email, action: :get_by_email, args: [:email]

      define_calculation :user_email_length, calculation: :email_length, args: [{:ref, :email}]
    end
  end
end
