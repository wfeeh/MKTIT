@isTest (seealldata = true)
global class TestGainsightFeaturesBatch implements Schedulable{

	static testMethod void GainsightFeaturesBatchTest() {

		// --------------- BEGIN SET UP --------------- //

		// Query for the standard price book ID
		String standardPriceBookID = '';
		Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
		standardPriceBookID = standardPriceBook.ID;

		// Create new Account
		Account A = new Account(
			Name = 'Test Account'
			);
		insert A;

		// Query for an ActiveCustomer Picklist
		JBCXM__Picklist__c PL = [SELECT Id FROM JBCXM__Picklist__c WHERE JBCXM__SystemName__c = 'ActiveCustomer' LIMIT 1];

		// Create new Customer Info
		JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(
			JBCXM__Account__c = A.ID,
			JBCXM__Status__c = PL.ID,
			JBCXM__MRR__c = 0,
			JBCXM__ASV__c = 0
			);
		insert CI;

		// Create new Opportunity
		Opportunity O = new Opportunity(
			Name = 'Test Opportunity',
			StageName = 'Closed Won',
			CloseDate = Date.today(),
			Type = 'New Business',
			Sub_Start_Date__c = date.valueOf('2013-01-01'),
			Sub_End_Date__c = Date.today(),
			AccountID = A.ID
			);
		insert O;

		// Create new Product
		Product2 P2 = new Product2(
			Name = 'Test Product',
			Family = 'Support',
			Product_Type__c = 'Test Product Type',
			isActive = true,
			ProductCode = 'TESTCODE'
			);
		insert P2;

		// Create new Pricebook Entry
		PricebookEntry PBE = new PricebookEntry(
			Product2ID = P2.ID,
			Pricebook2ID = standardPriceBookID,
			isActive = true,
			UnitPrice = 99,
			UseStandardPrice = false
			);
		insert PBE;

		// Create new Opportunity Line Item
		OpportunityLineItem OPLI = new OpportunityLineItem(
			PricebookEntryID = PBE.ID,
			OpportunityID = O.ID,
			Quantity = 1,
			TotalPrice = 99
			);
		insert OPLI;

		// ----------------- END SET UP ----------------- //


		Test.startTest();
		database.executebatch(new GainsightFeaturesBatch(A.ID), 1);
		Test.stopTest();

		// Update Sub_End_Date to test non-active Opportunities
		O.Sub_End_Date__c = date.valueOf('2013-02-02');
		update O;

		database.executebatch(new GainsightFeaturesBatch(A.ID), 1);
	}

	// Test batch scheduling
	static testMethod void GainsightFeaturesSchedulableTest() {
		GainsightFeaturesBatchSchedulable m = new GainsightFeaturesBatchSchedulable();
		string sch = '0 0 13 ? * SUN';
		system.schedule('Test Schedule', sch, m);
	}

	global void execute(SchedulableContext scMain) {
		database.executebatch(new GainsightFeaturesBatch(), 1);
	}
}