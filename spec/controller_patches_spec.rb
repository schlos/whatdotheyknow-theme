# If defined, ALAVETELI_TEST_THEME will be loaded in config/initializers/theme_loader
ALAVETELI_TEST_THEME = 'whatdotheyknow-theme'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','spec','spec_helper'))

describe RequestController, :type => :controller do

    context 'when the request has been successfully created' do

        it 'should assign "pending" flash messages, not the "notice" flash and redirect' do
            body = FactoryGirl.create(:public_body)
            user = FactoryGirl.create(:user)
            post :new, {:info_request => { :public_body_id => body.id,
                 :title => "Test request", :tag_string => "" },
                 :outgoing_message => { :body => "This is a silly letter." },
                 :submitted_new_request => 1, :preview => 0}, {:user_id => user.id}
            flash[:pending_title].should match("Your Freedom of Information request has been sent on its way!")
            flash[:pending].should match('We will email you')
            flash[:notice].should be_nil
            info_request = assigns[:info_request]
            response.should redirect_to show_new_request_url(:url_title => info_request.url_title)
        end

    end

    context 'when the request is still new' do

        it 'should redirect to the front page if no body is supplied and not assign "pending" flash' do
            get :new
            flash[:pending].should be_nil
            response.should redirect_to(:controller => 'general', :action => 'frontpage')
        end

        it 'should not assign "pending" flash on preview' do
            body = FactoryGirl.create(:public_body)
            user = FactoryGirl.create(:user)
            get :new, {:info_request => { :public_body_id => body.id,
                 :title => "Test request", :tag_string => "" },
                 :outgoing_message => { :body => "This is a silly letter." },
                 :submitted_new_request => 1, :preview => 1}, {:user_id => user.id}
            flash[:pending].should be_nil
            response.should render_template('preview')
        end

    end

end
