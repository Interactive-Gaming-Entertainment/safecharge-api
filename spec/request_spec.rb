#!/user/bin/env ruby
#coding: utf-8

require "safecharge/request"

describe Safecharge::Request do

  before :all do
	  # see https://test.safecharge.com/doc/Test_CreditCards.txt
	  @valid_cards = [
			'4000021059386316',
			'4000024473425231',
			'4000037434826586',
			'4000046595404935',
			'4000050320287425',
			'4000065919262217',
			'4000097446238923',
			'4444419078717848',
			'4444426864550804',
			'4444436501403986',
			'4444458284615321',
			'4444465389525081',
			'4444470762656560',
			'4444480853526820',
			'4444499431371889',
			'4444498667002689',
			'4444498051157677',
			'4444495866098625',
			'4444412360952876',
			'4000024059825994',
			'5100260315810893',
			'5100270690090656',
			'5100286513996754',
			'5333305231532763',
			'5333314109355505',
			'5333326770941868',
			'5333333139584041',
			'5333332933601845',
			'5333332230811667',
			'5333331746326111',
			'5333344683545239',
			'5333347342022912',
			'5333351770315269',
			'5333368254969676',
			'5333377040264581',
			'5333385639118126',
			'5333390439512403',
			'5333335034327954',
			'5333339469130529',
			'5333337896594614',
			'5333336113126473',
			'5333334054117130',
			'5333337861359175',
			'4012001036275556',
			'4012001038443335',
			'4012001036298889',
			'4012001036983332',
			'4012001037167778',
			'4012001037490014',
			'4005559876540',
			'36000023818683',
			'36000097503567',
			'6331101999990016'
		]
		
		@settings = { 'username' => 'dummy', 'password' => 'dummy' }

		if @settings['username'].empty? || @settings['password'].empty?
			raise RuntimeError, "Both username and password to SafeCharge API are required to run these tests"
		end

    @params = {
      'sg_FirstName'=>'John',
      'sg_LastName'=>'Smith',
      'sg_Address'=>'Elm Street, 13',
      'sg_City'=>'London',
      'sg_State'=>'London',
      'sg_Zip'=>'3031',
      'sg_Country'=>'GB',
      'sg_Phone'=>'123456790',
      'sg_Email'=>'john@smith.com',
      'sg_Is3dTrans' => 0,
      'sg_Currency' => 'GBP',
      'sg_Amount' => '99.99',
      'sg_NameOnCard' => 'John Smith',
      'sg_ExpMonth' => '12',
      'sg_ExpYear' => '13',
      'sg_CVV2' => '123'
    }

  end

  it "should create a request" do

		req = Safecharge::Request.new(@settings)
    req.should_not eq nil
    
  end

  it "should clean a card number" do
    dirty = '4000 0210 5938 6316'
		req = Safecharge::Request.new(@settings)
    req.clean_card_number(dirty).should eq '4000021059386316'
  end

#     TRANSACTION_TYPES = [
#       Safecharge::Constants::REQUEST_TYPE_AUTH,
#       Safecharge::Constants::REQUEST_TYPE_SETTLE,
#       Safecharge::Constants::REQUEST_TYPE_SALE,
#       Safecharge::Constants::REQUEST_TYPE_CREDIT,
#       Safecharge::Constants::REQUEST_TYPE_VOID,
#       Safecharge::Constants::REQUEST_TYPE_AVS
#     ]


  it "should do other stuff" do
		req = Safecharge::Request.new(@settings)
		req.type = Safecharge::Constants::REQUEST_TYPE_AUTH
		req.parameters = @params.merge({
  			'sg_ClientLoginID'  => 'test-only',
				'sg_ClientPassword' => 'hide me',
				'sg_IPAddress'      =>'127.0.0.1',
				'sg_CardNumber'     => @valid_cards.sample
    })
    req.params['sg_ClientLoginID'].should eq 'test-only'
  end

  it "should send a request" do
		result = []
		cards = @valid_cards.shuffle
		result = cards.map do |card|
			[ Safecharge::REQUEST_TYPE_AUTH, @params.merge({ 'sg_CardNumber' => card }) ]
		end

    result.each do |cr|
      type = cr[0]
      card = cr[1]
		  sf = Safecharge::Request.new(@settings);
		  sf.type = type
		  sf.parameters = card
		  # puts sf.clean_card_number(card['sg_CardNumber'])
      # safe_build = sf.build
      # puts "#{safe_build}"
    end

# 		$this->assertFalse(empty($result), "Result is empty");
# 		$this->assertTrue(is_object($result), "Result is not an XML object");
# 		$this->assertFalse(empty($result->TransactionID), "No transaction ID");
# 		$this->assertEquals(SafeCharge::RESPONSE_STATUS_APPROVED, (string) $result->Status, "Transaction not approved [" . $result->Status . "], reason: [" . $result->Reason . "]");
# 
  end

end
