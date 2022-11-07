require 'fastlane/action'
require 'net/http'
require_relative '../helper/jira_ticket_shipper_helper'

module Fastlane
  module Actions
    class JiraTicketShipperAction < Action
      def self.run(params)
        UI.message("The jira_ticket_shipper plugin is working!")
        tickets = params[:ticket_message].scan(/\w*KLIV-\w*/).uniq
        tickets.each { |ticket|
          uri = URI("#{params[:base_url]}/rest/api/3/issue/#{ticket}/transitions")
          req = Net::HTTP::Post.new(uri)
          req['Content-Type'] = "application/json"
          req['Authorization'] = "Basic #{params[:token]}"          
          req.body = {transition: { id: "#{params[:status_id]}"}}.to_json
          Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
            http.request(req)        
          end 
          
          uri = URI("#{params[:base_url]}/rest/api/3/issue/#{ticket}/comment")
          req = Net::HTTP::Post.new(uri)
          req['Content-Type'] = "application/json"
          req['Authorization'] = "Basic #{params[:token]}"          
          req.body = {body: { type: "doc", version: 1, content: [{type: "paragraph", content: [{text: "#{params[:comment]}", type: "text"}] }]}}.to_json
          Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
            http.request(req)        
          end 
        }    
        
      end

      def self.description
        "Transition Jira ticket to target status with comment"
      end

      def self.authors
        ["Billsp"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Transition Jira ticket to target status with comment"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
            env_name: 'TOKEN',
            description: 'Jira token, format: email@domain.com:<token>',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No token given") unless value and !value.empty?
            end),
          FastlaneCore::ConfigItem.new(key: :base_url,
            env_name: 'JIRA_URL',
            description: 'Jira host url, format: https://<host>.atlassian.net',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No repo name given") unless value and !value.empty?
            end),
          FastlaneCore::ConfigItem.new(key: :ticket_patern,
            env_name: 'TICKET_PATERN',
            description: 'Ticket patern to detect, format: XXXX-',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No repo name given") unless value and !value.empty?
            end),            
          FastlaneCore::ConfigItem.new(key: :ticket_message,
            env_name: 'TICKET_MESSAGE',
            description: 'Message contain any ticket id, format: #XXX-1921 asalso & #XWO-121',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No repo name given") unless value and !value.empty?
            end),
          FastlaneCore::ConfigItem.new(key: :status_id,
            env_name: 'TARGET_STATUS_ID',
            description: 'Target status Id, format: 31',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No repo name given") unless value and !value.empty?
            end),
          FastlaneCore::ConfigItem.new(key: :comment,
            env_name: 'COMMENT',
            description: 'What ever you want to comment',
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("No repo name given") unless value and !value.empty?
            end)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
