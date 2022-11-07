describe Fastlane::Actions::JiraTicketShipperAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_ticket_shipper plugin is working!")

      Fastlane::Actions::JiraTicketShipperAction.run(nil)
    end
  end
end
