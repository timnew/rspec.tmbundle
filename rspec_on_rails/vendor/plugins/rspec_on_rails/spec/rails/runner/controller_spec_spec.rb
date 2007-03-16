require File.dirname(__FILE__) + '/../../spec_helper'
require 'controller_isolation_spec_controller'

['integration', 'isolation'].each do |mode|
  context "Given a controller spec for ControllerIsolationSpecController running in #{mode} mode", :context_type => :controller do
    controller_name :controller_isolation_spec
    integrate_views if mode == 'integration'
  
    specify "session should be the same object as controller session" do
      get 'action_with_template'
      session.should equal(controller.session)
    end
  
    specify "session should be the same object before and after the action" do
      session_before = session
      get 'action_with_template'
      session.should equal(session_before)
    end
  
    specify "controller.session should NOT be nil before the action" do
      controller.session.should_not be_nil
      get 'action_with_template'
    end
    
    specify "controller.session should NOT be nil after the action" do
      get 'action_with_template'
      controller.session.should_not be_nil
    end
    
    specify "specifying a partial should work with partial name only" do
      get 'action_with_partial'
      response.should render_template("_a_partial")
    end
    
    specify "specifying a partial should work with path relative to RAILS_ROOT/app/views/" do
      get 'action_with_partial'
      response.should render_template("controller_isolation_spec/_a_partial")
    end
    
    specify "spec should have access to flash" do
      get 'action_with_template'
      flash[:flash_key].should == "flash value"
    end

    specify "spec should have access to session" do
      get 'action_with_template'
      session[:session_key].should == "session value"
    end

    specify "custom routes should be speccable" do
      route_for(:controller => "custom_route_spec", :action => "custom_route").should == "/custom_route"
    end

    specify "routes should be speccable" do
      route_for(:controller => "controller_isolation_spec", :action => "some_action").should == "/controller_isolation_spec/some_action"
    end
  end

  context "Given a controller spec for RedirectSpecController running in #{mode} mode", :context_type => :controller do
    controller_name :redirect_spec
    integrate_views if mode == 'integration'

    specify "a redirect should ignore the absence of a template" do
      get 'action_with_redirect_to_somewhere'
      response.should be_redirect
      response.redirect_url.should == "http://test.host/redirect_spec/somewhere"
      response.should redirect_to("http://test.host/redirect_spec/somewhere")
    end
    
    specify "a call to response.should redirect_to should fail if no redirect" do
      get 'action_with_no_redirect'
      lambda {
        response.redirect?.should be_true
      }.should fail
      lambda {
        response.should redirect_to("http://test.host/redirect_spec/somewhere")
      }.should fail_with("expected redirect to \"http://test.host/redirect_spec/somewhere\", got no redirect")
    end
  end
  
  context "Given a controller spec running in #{mode} mode", :context_type => :controller do
    integrate_views if mode == 'integration'
    specify "a spec in a context without controller_name set should fail with a useful warning",
      :should_raise => [
        Spec::Expectations::ExpectationNotMetError,
        /You have to declare the controller name in controller specs/
      ] do
    end
  end
  
  
end

