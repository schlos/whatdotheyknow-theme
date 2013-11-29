Rails.configuration.to_prepare do
    UserController.class_eval do
        require 'survey'

        def survey
        end

        # Reset the state of the survey so it can be answered again.
        # Handy for testing; not allowed in production.
        def survey_reset
            raise "Not allowed in production" if ENV["RAILS_ENV"] == "production"
            raise "Not logged in" if !@user
            @user.survey.allow_new_survey
            return redirect_to survey_url
        end
    end

    GeneralController.class_eval do
        def frontpage
            medium_cache
            @locale = self.locale_from_params()
            # Get some successful requests to display as examples:
            begin
                query = 'variety:response (status:successful OR status:partially_successful)'
                sortby = "newest"
                max_count = 3
                xapian_object = perform_search([InfoRequestEvent], query, sortby, 'request_title_collapse', max_count)
                @request_events = xapian_object.results.map { |r| r[:model] }

                # If there are not yet enough successful requests, fill out the list with
                # other requests
                if @request_events.count < max_count
                    @request_events_all_successful = false
                    query = 'variety:sent'
                    xapian_object = perform_search([InfoRequestEvent], query, sortby, 'request_title_collapse', max_count-@request_events.count)
                    more_events = xapian_object.results.map { |r| r[:model] }
                    @request_events += more_events
                    # Overall we still want the list sorted with the newest first
                    @request_events.sort!{|e1,e2| e2.created_at <=> e1.created_at}
                else
                    @request_events_all_successful = true
                end
            rescue
                @request_events = []
            end
        end

        def tmp_email_alerts
        end

    end

    RequestController.class_eval do

        def use_pending_flash
            if @info_request && !@info_request.new_record?
                flash.delete(:notice)
                flash[:pending_title] = _("Your {{law_used_full}} request has been sent on its way!",
                                          :law_used_full=>@info_request.law_used_full)
                flash[:pending] = _("<p><strong>We will email you</strong> when there is a response, or after
                                    {{late_number_of_days}} working days if the authority still hasn't
                                    replied by then.</p>
                                    <p>If you write about this request (for example in a forum or a blog)
                                    please link to this page, and add an annotation below telling people
                                    about your post.</p>",
                                    :late_number_of_days => AlaveteliConfiguration::reply_late_after_days)
            end
        end

        def new_with_use_pending_flash
            new_without_use_pending_flash
            use_pending_flash
        end

        alias_method_chain :new, :use_pending_flash
    end


end
