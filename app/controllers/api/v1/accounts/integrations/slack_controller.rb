class Api::V1::Accounts::Integrations::SlackController < Api::V1::Accounts::BaseController
  before_action :fetch_hook, only: [:update, :destroy]

  def create
    builder = Integrations::Slack::HookBuilder.new(
      account: current_account,
      code: params[:code],
      inbox_id: params[:inbox_id]
    )
    @hook = builder.perform
    create_chatwoot_slack_channel
  end

  def update
    create_chatwoot_slack_channel
    render json: @hook
  end

  def destroy
    @hook.destroy

    head :ok
  end

  private

  def fetch_hook
    @hook = Integrations::Hook.find_by(app_id: 'slack')
  end

  def create_chatwoot_slack_channel
    channel = params[:channel] || 'customer-conversations'
    builder = Integrations::Slack::ChannelBuilder.new(
      hook: @hook, channel: channel
    )
    builder.perform
  end
end
