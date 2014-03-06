//Generated by wsdl2apex

public class creditappDtoEaiDnbiCom {
    public class CompanyInfoDTO {
        public String address;
        public String city;
        public String companyName;
        public String phone;
        public String state;
        public String zipCode;
        public String country;
        private String[] address_type_info = new String[]{'address','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] city_type_info = new String[]{'city','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] companyName_type_info = new String[]{'companyName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] phone_type_info = new String[]{'phone','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] state_type_info = new String[]{'state','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] zipCode_type_info = new String[]{'zipCode','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] country_type_info = new String[]{'country','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'address','city','companyName','phone','state','zipCode','country'};
    }
    public class GetListOfApplicationsRequestDTO {
        public String businessName;
        public Boolean exactMatchRequired;
        public String workflowStatus;
        private String[] businessName_type_info = new String[]{'businessName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] exactMatchRequired_type_info = new String[]{'exactMatchRequired','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] workflowStatus_type_info = new String[]{'workflowStatus','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'businessName','exactMatchRequired','workflowStatus'};
    }
    public class GetCreditApplicationsResultDTO {
        public creditappDtoEaiDnbiCom.ArrayOfCreditApplicationDTO creditApplications;
        public Boolean incompleteMatchListReturned;
        private String[] creditApplications_type_info = new String[]{'creditApplications','http://creditapp.dto.eai.dnbi.com','ArrayOfCreditApplicationDTO','0','1','true'};
        private String[] incompleteMatchListReturned_type_info = new String[]{'incompleteMatchListReturned','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'creditApplications','incompleteMatchListReturned'};
    }
    public class ArrayOfCreditApplicationDTO {
        public creditappDtoEaiDnbiCom.CreditApplicationDTO[] CreditApplicationDTO;
        private String[] CreditApplicationDTO_type_info = new String[]{'CreditApplicationDTO','http://creditapp.dto.eai.dnbi.com','CreditApplicationDTO','0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'CreditApplicationDTO'};
    }
    public class CreditApplicationDTO {
        public String applicationId;
        public dtoEaiDnbiCom.ArrayOfBureauIdDTO bureauIdList;
        public dtoEaiDnbiCom.BusinessEntityDTO business;
        public String status;
        private String[] applicationId_type_info = new String[]{'applicationId','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] bureauIdList_type_info = new String[]{'bureauIdList','http://dto.eai.dnbi.com','ArrayOfBureauIdDTO','0','1','true'};
        private String[] business_type_info = new String[]{'business','http://dto.eai.dnbi.com','BusinessEntityDTO','0','1','true'};
        private String[] status_type_info = new String[]{'status','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationId','bureauIdList','business','status'};
    }
    public class PerformECFActionRequestDTO {
        public String applicationNumber;
        public String asigneeName;
        public String asigneeType;
        public Boolean createAccountFlag;
        public dtoEaiDnbiCom.CreditTermsDTO creditTerms;
        public comDnbiEaiServiceCreditapplication.ArrayOfString decisionReasons;
        public Boolean updateApplication;
        public String workflowAction;
        private String[] applicationNumber_type_info = new String[]{'applicationNumber','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] asigneeName_type_info = new String[]{'asigneeName','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] asigneeType_type_info = new String[]{'asigneeType','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] createAccountFlag_type_info = new String[]{'createAccountFlag','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] creditTerms_type_info = new String[]{'creditTerms','http://dto.eai.dnbi.com','CreditTermsDTO','0','1','true'};
        private String[] decisionReasons_type_info = new String[]{'decisionReasons','http://com.dnbi.eai.service.CreditApplication','ArrayOfString','0','1','true'};
        private String[] updateApplication_type_info = new String[]{'updateApplication','http://www.w3.org/2001/XMLSchema','boolean','0','1','false'};
        private String[] workflowAction_type_info = new String[]{'workflowAction','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationNumber','asigneeName','asigneeType','createAccountFlag','creditTerms','decisionReasons','updateApplication','workflowAction'};
    }
    public class CreditApplicationECFDTO {
        public creditappDtoEaiDnbiCom.CreditApplicationDTO application;
        public dtoEaiDnbiCom.ArrayOfFieldDTO applicationValues;
        public dtoEaiDnbiCom.CreditTermsDTO creditTerms;
        public dtoEaiDnbiCom.OutcomeDTO decisionOutcome;
        public dtoEaiDnbiCom.ArrayOfScoreDTO scoreList;
        private String[] application_type_info = new String[]{'application','http://creditapp.dto.eai.dnbi.com','CreditApplicationDTO','0','1','true'};
        private String[] applicationValues_type_info = new String[]{'applicationValues','http://dto.eai.dnbi.com','ArrayOfFieldDTO','0','1','true'};
        private String[] creditTerms_type_info = new String[]{'creditTerms','http://dto.eai.dnbi.com','CreditTermsDTO','0','1','true'};
        private String[] decisionOutcome_type_info = new String[]{'decisionOutcome','http://dto.eai.dnbi.com','OutcomeDTO','0','1','true'};
        private String[] scoreList_type_info = new String[]{'scoreList','http://dto.eai.dnbi.com','ArrayOfScoreDTO','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'application','applicationValues','creditTerms','decisionOutcome','scoreList'};
    }
    public class UpdateCreditApplicationRequestDTO {
        public String applicationNumber;
        public dtoEaiDnbiCom.CreditTermsDTO creditTermsDTO;
        public dtoEaiDnbiCom.ArrayOfFieldDTO fieldList;
        private String[] applicationNumber_type_info = new String[]{'applicationNumber','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] creditTermsDTO_type_info = new String[]{'creditTermsDTO','http://dto.eai.dnbi.com','CreditTermsDTO','0','1','true'};
        private String[] fieldList_type_info = new String[]{'fieldList','http://dto.eai.dnbi.com','ArrayOfFieldDTO','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'applicationNumber','creditTermsDTO','fieldList'};
    }
    public class BureauErrorDTO {
        public String errorCode;
        public String errorMessage;
        public String recommendedAction;
        private String[] errorCode_type_info = new String[]{'errorCode','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] errorMessage_type_info = new String[]{'errorMessage','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] recommendedAction_type_info = new String[]{'recommendedAction','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'errorCode','errorMessage','recommendedAction'};
    }
    public class CorporateLinkageDTO {
        public String dunsNo;
        public String glbUltimateDunsNo;
        public String hqDunsNo;
        public String parentDunsNo;
        private String[] dunsNo_type_info = new String[]{'dunsNo','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] glbUltimateDunsNo_type_info = new String[]{'glbUltimateDunsNo','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] hqDunsNo_type_info = new String[]{'hqDunsNo','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] parentDunsNo_type_info = new String[]{'parentDunsNo','http://www.w3.org/2001/XMLSchema','string','0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://creditapp.dto.eai.dnbi.com','true','true'};
        private String[] field_order_type_info = new String[]{'dunsNo','glbUltimateDunsNo','hqDunsNo','parentDunsNo'};
    }
}