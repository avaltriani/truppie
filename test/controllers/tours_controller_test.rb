include Devise::TestHelpers
require 'test_helper'
require 'json'

class ToursControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  setup do
    sign_in users(:alexandre)
    @tour = tours(:morro)
    @tour_marins = tours(:picomarins)
    
    @payment_data = {
      id: @tour,
      method: "CREDIT_CARD",
      expiration_month: 04,
      expiration_year: 18,
      number: "4012001038443335",
      cvc: "123",
      fullname: "Alexandre Magno Teles Zimerer",
      birthdate: "10/10/1988",
      cpf_number: "22222222222",
      country_code: "55",
      area_code: "11",
      phone_number: "55667788",
      value: @tour.value
    }
    
    @boleto = {
      expirationDate: "2016-09-30",
      instructionLines: {
        first: "Primeira linha se instrução",
        second: "Segunda linha se instrução",
        third: "Terceira linha se instrução"
      },
    }
    
    @payment_data_boleto = {
      id: @tour,
      method: "BOLETO",
      value: @tour.value,
    }
    
    
    @basic_tour = {
      title: "A basic truppie",
      organizer: Organizer.first.name,
      where: Where.last.name
    }
    
    @basic_empty_tour_with_empty = {
      title: "Another basic truppie",
      organizer: Organizer.first.name,
      where: Where.last.name,
      description: "",
      rating: "",
      value: "",
      currency: "",
      start: "",
      end: "",
      photo: "",
      availability: "",
      minimum: "",
      maximum: "",
      difficulty: "",
      address: "",
      included: "",
      nonincluded: "",
      take: "",
      goodtoknow: "",
      category: Category.last.id,
      tags: "",
      attractions: "",
      privacy: "",
      meetingpoint: "",
      #confirmed: "",
      languages: "",
      verified: "",
      status: ""
    }
    
  end
  
  #teardown do
    #DatabaseCleaner.clean
  #end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tours)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should not create tour with empty data" do
     #skip("creating tour with empty data")
     post :create, tour: {}
     assert_equal 'o campo title não pode ficar em branco', flash[:notice]
     #assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "should not create tour with organizer without a title" do
     #skip("creating tour with empty data")
     post :create, tour: {organizer: Organizer.first.name}
     assert_equal 'o campo title não pode ficar em branco', flash[:notice]
     #assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "should not create tour with no organizer but with a title" do
     #skip("creating tour with empty data")
     post :create, tour: {title: 'foo truppie title'}
     assert_equal 'o campo organizer não pode ficar em branco', flash[:notice]
     #assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "should create tour with success flash" do
     #skip("creating tour with organizer")
     #puts @basic_tour.inspect
     post :create, tour: @basic_tour
     assert_equal 'Truppie criada com sucesso', flash[:notice]
   end
  
  test "should create tour with basic data" do
     #skip("creating tour with organizer")
     assert_difference('Tour.count') do
       post :create, tour: @basic_tour
     end
     assert_redirected_to tour_path(assigns(:tour))
   end
   
  test "should create tour with basic data with form empty sets" do
     #skip("creating tour with organizer")
     assert_difference('Tour.count') do
       post :create, tour: @basic_empty_tour_with_empty
     end
     assert_redirected_to tour_path(assigns(:tour))
   end
   
   test "should associate tags" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["tags"] = "#{Tag.last.name};anothertag"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.tags[0].name, "family"
     assert_equal Tour.last.tags[1].name, "anothertag"
     assert_equal Tag.last.name, "anothertag"
   end
   
   test "should associate languages" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["languages"] = "#{languages(:english).name};#{languages(:portuguese).name}"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.languages[0].name, "english"
     assert_equal Tour.last.languages[1].name, "portuguese"
   end
   
   test "should create includeds" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["included"] = "almoco;jantar;cafe"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.included[0], "almoco"
     assert_equal Tour.last.included[1], "jantar"
     assert_equal Tour.last.included[2], "cafe"
   end
   
   test "should create nonincludeds" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["nonincluded"] = "almoco;jantar;cafe"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.nonincluded[0], "almoco"
     assert_equal Tour.last.nonincluded[1], "jantar"
     assert_equal Tour.last.nonincluded[2], "cafe"
   end
   
   test "should create itens to take" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["take"] = "almoco;jantar;cafe"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.take[0], "almoco"
     assert_equal Tour.last.take[1], "jantar"
     assert_equal Tour.last.take[2], "cafe"
   end
   
   test "should create itens good to know" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["goodtoknow"] = "almoco;jantar;cafe"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.goodtoknow[0], "almoco"
     assert_equal Tour.last.goodtoknow[1], "jantar"
     assert_equal Tour.last.goodtoknow[2], "cafe"
   end
   
   test "should create with category" do
     #skip("creating tour with tags")
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.category.name, "Trekking"
   end
   
   test "should create with new category" do
     #skip("creating tour with cat")
     @basic_empty_tour_with_empty["category"] = "Nova"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.category.name, "Nova"
   end
   
   test "should create with packages" do
     @basic_empty_tour_with_empty["packages_attributes"] = {"0"=>{"name"=>"Barato", "value"=>"10", "included"=>"barato;caro"}}
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.packages.first.name, "Barato"
     assert_equal Tour.last.packages.first.included, ["barato", "caro"]
   end
   
   test "should create truppie with a given start" do
     #skip("creating tour with tags")
     @basic_empty_tour_with_empty["start"] = "2016-02-02T11:00"
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.start, "Tue, 02 Feb 2016 11:00:00 UTC +00:00"
   end
   
   test "should create withe the current status non published for default" do
     post :create, tour: @basic_empty_tour_with_empty
     
     assert_equal Tour.last.status, ""
   end

  test "should show tour" do
    get :show, id: @tour
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tour
    assert_response :success
  end

  test "should update tour" do
    skip("update tour")
    patch :update, id: @tour, tour: {  }
    assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "increment one more member" do
    @tour_confirmed_before = @tour.confirmeds.count
    post :confirm_presence, @payment_data
    @tour_confirmed_after = @tour.confirmeds.count
    assert_equal @tour_confirmed_before + 1, @tour_confirmed_after
  end
  
  test "should go to confirm presence with confirming price default" do
    get :confirm, {id: @tour}
    assert(assigns(:final_price))
    assert_equal(assigns(:final_price), 40)
    
  end
  
  test "should go to confirm presence with confirming package" do
    get :confirm, {id: @tour_marins, packagename: @tour_marins.packages.first.name}
    assert(assigns(:final_price))
    assert_equal(assigns(:final_price), 320)
  end
    
  test "should confirm presence" do
    post :confirm_presence, @payment_data
    assert_equal assigns(:confirm_headline_message), "Sua presença foi confirmada para a truppie"
    assert_equal assigns(:confirm_status_message), "Você receberá um e-mail sobre o processamento do seu pagamento"
    assert_equal assigns(:status), "success"
    assert_template "confirm_presence"
  end
  
  test "should add order to confirmed presence" do 
    post :confirm_presence, @payment_data
    assert_equal Tour.find(@tour.id).orders.any?, true 
  end
  
  test "should not confirm presence with no payment" do
    post :confirm_presence, {id: @tour}
    assert_equal assigns(:confirm_headline_message), "Não foi possível confirmar sua reserva"
    assert_equal assigns(:confirm_status_message), "Você não forneceu dados suficientes para o pagamento"
    assert_equal assigns(:status), "danger"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal Tour.find(@tour.id).orders.any?, false
  end
  
  test "should not confirm again" do
    post :confirm_presence, @payment_data
    post :confirm_presence, @payment_data
    assert_equal "Hey, você já está confirmado neste evento!!", flash[:error]
    assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "should not confirm if soldout" do
    @tour.confirmeds.create(user: users(:laura))
    @tour.confirmeds.create(user: users(:ciclano))
    @tour.update_attributes(:reserved => 3)
    post :confirm_presence, @payment_data
    assert_equal assigns(:confirm_headline_message), "Não foi possível confirmar sua reserva"
    assert_equal assigns(:confirm_status_message), "Este evento está esgotado"
    assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "should unconfirm" do
    @tour.confirmeds.create(user: users(:alexandre))
    @tour.update_attributes(:reserved => 2)
    assert_equal @tour.available, 1
    post :unconfirm_presence, @payment_data
    assert_equal "Você não está mais confirmardo neste evento", flash[:success]
    assert_equal Tour.find(@tour.id).available, 3
    assert_redirected_to tour_path(assigns(:tour))
  end
  
  test "should create a order with the given id" do
    post :confirm_presence, @payment_data
    assert_equal assigns(:confirm_headline_message), "Sua presença foi confirmada para a truppie"
    assert_equal assigns(:confirm_status_message), "Você receberá um e-mail sobre o processamento do seu pagamento"
    assert_equal assigns(:status), "success"
    assert_template "confirm_presence"
    assert_includes ["IN_ANALYSIS", "AUTHORIZED"], Order.last.status
  end
  
  test "should access the payment generated by order" do
    #skip("consult payment")
    post :confirm_presence, @payment_data
    payment_id = Order.last.payment
    
    headers = {
      :content_type => 'application/json',
      :authorization => Rails.application.secrets[:moip_auth]
    }
    
    response = RestClient.get "https://sandbox.moip.com.br/v2/payments/#{payment_id}", headers
    json_data = JSON.parse(response)
    assert_equal payment_id, json_data["id"]
    assert_equal 4000, json_data["amount"]["total"]
  end
  
  test "should divide in two the payment generated by order" do
    #skip("consult payment")
    @payment_data["installment_count"] = 2
    post :confirm_presence, @payment_data
    payment_id = Order.last.payment
    
    headers = {
      :content_type => 'application/json',
      :authorization => Rails.application.secrets[:moip_auth]
    }
    
    response = RestClient.get "https://sandbox.moip.com.br/v2/payments/#{payment_id}", headers
    json_data = JSON.parse(response)
    # puts json_data.inspect
    assert_equal 2, json_data["installmentCount"]
  end
  
  
  #
  #
  # Other payment type
  #
  #
  
  
  test "should create a payment with credit card" do
    post :confirm_presence, @payment_data
    
    order = Order.last
    
    assert_equal assigns(:payment_method), "CREDIT_CARD"
    assert_equal order.payment_method, "CREDIT_CARD"
  end
  
  test "should create a payment with boleto gives a error message when date expiration is over" do
    #skip("time based")
    @tour.start = Date.new(2012, 9, 30)
    @tour.save()
    post :confirm_presence, @payment_data_boleto
    assert_equal assigns(:payment_api_error), "fundingInstrument.boleto.validExpirationDate"
    #puts ActionMailer::Base.deliveries[0].inspect
    #assert_not ActionMailer::Base.deliveries[0].html_part.nil?
    assert_equal ActionMailer::Base.deliveries.last.to, ['ola@truppie.com', 'organizer@mail.com']
    assert_equal ActionMailer::Base.deliveries.last.subject, "Algo errado na tentativa de pagamento para a sua truppie - #{@tour.title}"
    
  end
  
  test "should create a payment with boleto if the right date" do
    #@payment_data_boleto[:expirationDate] = "2077-09-30"
    @tour.update_attribute(:start, Date.new(2077, 9, 30))
    post :confirm_presence, @payment_data_boleto
    
    order = Order.last
    
    assert_equal assigns(:payment_method), "BOLETO"
    assert_equal assigns(:payment_api_success)[:_links][:self][:href], "https://sandbox.moip.com.br/v2/payments/#{order.payment}"
    assert_equal assigns(:payment_api_success_url), "https://checkout-sandbox.moip.com.br/boleto/#{order.payment}"
    assert_equal assigns(:payment_api_success)["funding_instrument"][:boleto][:instruction_lines][:first], @tour.title
    assert_equal assigns(:payment_api_success)["funding_instrument"][:boleto][:instruction_lines][:second], @tour.organizer.name
    assert_equal assigns(:payment_api_success)["funding_instrument"][:boleto][:instruction_lines][:third], "Reservado por #{order.user.name}"
    assert_equal assigns(:payment_api_success)["funding_instrument"][:boleto][:instruction_lines][:third], "Reservado por #{order.user.name}"
    #assert_equal assigns(:payment_api_success)["funding_instrument"][:boleto][:expiration_date], @tour.start.to_date.strftime('%Y-%m-%d')
  end
  
  test "should create a payment with boleto that the billing date is 72h before" do
    #@payment_data_boleto[:expirationDate] = "2077-09-30"
    @tour.start = Date.new(2077, 9, 30).to_date
    @tour.save()
    post :confirm_presence, @payment_data_boleto
    assert_equal assigns(:payment_api_success)["funding_instrument"][:boleto][:expiration_date], (@tour.start - 72.hours).strftime('%Y-%m-%d')      
  end
  
  test "should create a payment with boleto that the billing date will exceed 72 hours" do
    @tour.start = Time.now + 24.hours
    @tour.save()
    post :confirm_presence, @payment_data_boleto
    assert_equal assigns(:payment_api_error), "fundingInstrument.boleto.validExpirationDate"
    #puts ActionMailer::Base.deliveries[0].to.inspect
    #assert_not ActionMailer::Base.deliveries[0].html_part.nil?
    assert_equal ActionMailer::Base.deliveries.last.to, ['ola@truppie.com', 'organizer@mail.com']
    assert_equal ActionMailer::Base.deliveries.last.subject, "Algo errado na tentativa de pagamento para a sua truppie - #{@tour.title}"
  end 
    
  #
  #
  # Reservation
  #
  #
  
  test "should process a reservation to more people with unlimited availability" do
    @tour.update_attributes(:availability => nil)
    @payment_data["amount"] = 2
    @payment_data["final_price"] = @tour.value * 2
    post :confirm_presence, @payment_data
    assert_equal(assigns(:amount), 2)
    assert_equal(assigns(:final_price), @tour.value * 2)
    order = Order.last
    
    assert_equal @tour.available, nil
  end
  
  test "should process a reservation to more people with limited availability" do
    @payment_data["amount"] = 2
    @payment_data["final_price"] = @tour.value * 2
    
    post :confirm_presence, @payment_data
    assert_equal(assigns(:amount), 2)
    assert_equal(assigns(:final_price), @tour.value * 2)
    assert_equal(assigns(:reserved_increment), 2)
    order = Order.last
    assert_equal Tour.order("updated_at").last.available, 1
    
  end
  
  test "should pass a valid birthdate" do
    #skip("valid birthdate")
    post :confirm_presence, @payment_data
    payment_id = Order.last.payment
    
    headers = {
      :content_type => 'application/json',
      :authorization => Rails.application.secrets[:moip_auth]
    }
    
    response = RestClient.get "https://sandbox.moip.com.br/v2/payments/#{payment_id}", headers
    json_data = JSON.parse(response)
    assert_equal '1988-10-10', json_data["fundingInstrument"]["creditCard"]["holder"]["birthdate"]
  end
  
  # test "should destroy tour" do
    # assert_difference('Tour.count', -1) do
      # delete :destroy, id: @tour
    # end
# 
    # assert_redirected_to tours_path
  # end
end
