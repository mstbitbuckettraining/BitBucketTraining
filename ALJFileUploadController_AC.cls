/*************************************************************************************************************
* Name              :  ALJFileUploadController_AC
* Summary           :  This controller used to upload the files to ALJ that creates matter records
* Author            :  MST
* Date              :  04/20/2018
*
* Modification Log :
* Developer                 Date                   Description
* -----------------------------------------------------------------------------------------------------------                 
*	Oliver				04/20/2018				ICA-3967 - ALJ Community Upload
*	Kanchana			04/24/2018				ICA-3989 - ALJ - Upload other documents from community
*	Oliver				06/19/2018				ICA-3322 - Request for Change of Arbitrator/Judge/Affidavit
*	Oliver				07/18/2018				ICA-3565 - Civil Penalities
*	Oliver				07/31/2018				ICA-5123 - New field on community when users upload Vexatious Litigant Motion
*************************************************************************************************************/
public without sharing class ALJFileUploadController_AC {
    @AuraEnabled
    public List<String> docTypeList { get; set; }
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    @AuraEnabled
    public Claim__c claimRec { get; set; }
    @AuraEnabled
    public Matter__c matterRec { get; set; }
    @AuraEnabled
    public Related_Doc__c commentval {get; set; }
    @AuraEnabled
    public String vexatiousMatter { get; set; }
    public static Boolean Valid { get; set; }
    
    //Method to get parent Id for Upload Component
    @AuraEnabled
    public static ALJFileUploadController_AC initRelatedDoc() {
        ALJFileUploadController_AC fileUpload = new ALJFileUploadController_AC();
        fileUpload.docTypeList = new List<String>();
        //ICA
        for(Inbound_Document__mdt docType : getMatterCreateInboundDocs()) {
            if(docType.Document_Type__c != Null) {
                fileUpload.docTypeList.add(docType.Document_Name__c);
            }
        }
        List<Claim__c> dummyClaimList = [SELECT Id FROM Claim__c WHERE Name =: System.Label.Claim_Number_Dummy LIMIT 1];
        if(dummyClaimList.size() != 0) {
            fileUpload.vexatiousMatter = Constants_AC.docVexatious;
            fileUpload.isSuccess = True;
            fileUpload.claimRec = dummyClaimList.get(0);
        }
        return fileUpload;
    }
    //ICA-3989 - ALJ - Upload other documents from community
    //Method to get parent Id for Upload Component
    @AuraEnabled
    public static ALJFileUploadController_AC initDoc() {
        ALJFileUploadController_AC fileUpload = new ALJFileUploadController_AC();
        fileUpload.docTypeList = new List<String>();
        //ICA
        for(Inbound_Document__mdt docType : getInboundDocs()) {
            if(docType.Document_Type__c != Null) {
                fileUpload.docTypeList.add(docType.Document_Name__c);
            }
        }
        /* List<Claim__c> dummyClaimList = [SELECT Id FROM Claim__c WHERE Name =: System.Label.Claim_Number_Dummy LIMIT 1];
if(dummyClaimList.size() != 0) {
fileUpload.isSuccess = True;
fileUpload.claimRec = dummyClaimList.get(0);
}*/
        return fileUpload;
    }
    
    //Method to get Metadata records
    public static List<Inbound_Document__mdt> getInboundDocs() {
        Set<Id> profileIdSet = new Set<Id>();
        for(Profile commProfile : [SELECT Id,Name FROM Profile WHERE Name='Community-Claimant' OR Name='Community-Attorney' OR Name= 'Community-Carrier' OR Name='Community-Employer']) {
            profileIdSet.add(commProfile.id);
        }
        if(profileIdSet.size() != 0 && profileIdSet.contains(UserInfo.getProfileID())) {
            return new List<Inbound_Document__mdt>([SELECT Id,MasterLabel,DeveloperName,Document_Name__c,Hide_in_Community__c,Document_Type__c FROM Inbound_Document__mdt WHERE ALJ_DocType__c = TRUE AND Hide_in_Community__c = False ORDER BY Document_Name__c ASC]);
        }
        else {
            return new List<Inbound_Document__mdt>([SELECT Id,MasterLabel,DeveloperName,Document_Name__c,Document_Type__c,Hide_in_Community__c FROM Inbound_Document__mdt WHERE ALJ_DocType__c = TRUE ORDER BY Document_Name__c ASC]);
        }
    }
    
    //Method to get Metadata records
    public static List<Inbound_Document__mdt> getMatterCreateInboundDocs() {
        Set<Id> profileIdSet = new Set<Id>();
        for(Profile commProfile : [SELECT Id,Name FROM Profile WHERE Name='Community-Claimant' OR Name='Community-Attorney' OR Name= 'Community-Carrier' OR Name='Community-Employer']) {
            profileIdSet.add(commProfile.id);
        }
        if(profileIdSet.size() != 0 && profileIdSet.contains(UserInfo.getProfileID())) {
            return new List<Inbound_Document__mdt>([SELECT Id,MasterLabel,DeveloperName,Document_Name__c,Hide_in_Community__c,Document_Type__c FROM Inbound_Document__mdt WHERE Matter_Create_DocType__c = TRUE AND Hide_in_Community__c = False ORDER BY Document_Name__c ASC]);
        }
        else {
            return new List<Inbound_Document__mdt>([SELECT Id,MasterLabel,DeveloperName,Document_Name__c,Document_Type__c,Hide_in_Community__c FROM Inbound_Document__mdt WHERE Matter_Create_DocType__c = TRUE ORDER BY Document_Name__c ASC]);
        }
    }
    
    //Method to get claim record from claim number
    @AuraEnabled
    public static ALJFileUploadController_AC getclaimRecordId(String claimNo) {
        ALJFileUploadController_AC fileUpload = new ALJFileUploadController_AC();
        List<Claim__c> claimList = [SELECT Id FROM Claim__c WHERE Name =: claimNo LIMIT 1];
        if(!claimList.isEmpty()) {
            fileUpload.claimRec = claimList.get(0);
            fileUpload.isSuccess = True;
        }
        else{
            fileUpload.isSuccess = False;
        }
        return fileUpload;
    }
    //ICA-3989 - ALJ - Upload other documents from community
    //Method to get Matter record from Matter number
    @AuraEnabled
    public static ALJFileUploadController_AC getMatterRecordId(String claimNo,String MatterNumber) {
        ALJFileUploadController_AC fileUpload = new ALJFileUploadController_AC();
        List<Claim__c> claimList = [SELECT Id FROM Claim__c WHERE Name =: claimNo LIMIT 1];
        if(!claimList.isEmpty()) {
            //fileUpload.claimRec = claimList.get(0);
            fileUpload.isSuccess = True;
            Valid = true;
        }
        else{
            fileUpload.isSuccess = False;
            Valid = False;
        }
        List<Matter__c> matterList = [SELECT Id,Claimant_First_Name__c, Claimant_Last_Name__c  FROM Matter__c WHERE Name =: MatterNumber LIMIT 1];
        if(!matterList.isEmpty() && Valid) {
            fileUpload.matterRec = matterList.get(0);
            fileUpload.isSuccess = True;
        }
        else{
            fileUpload.isSuccess = False;
        }
        return fileUpload;
    } 
    
    //Method to submit document for creation of a matter record
    @AuraEnabled
    public static String submitRecord(Id claimId, String claimNo, String content,String comment) {
        List<Claim__c> dummyClaimList = [SELECT Id FROM Claim__c WHERE Name =: System.Label.Claim_Number_Dummy LIMIT 1];
        Id dummyClaimId;
        if(dummyClaimList.size() != 0) {
            dummyClaimId = dummyClaimList.get(0).Id;
        }
        System.debug(
            'Claim ID : '+claimId+
            'ClaimNo : '+claimNo+
           
            'content : '+content+
            'dummyClaimId : '+dummyClaimId
        );
        
        List<contentWrapper> contentMapList = (List<contentWrapper>)System.JSON.deserialize(content, List<contentWrapper>.class);
        
        Set<ID> contentToDeleteIDs = new Set<ID>();
        List<ContentDocumentLink> linksToInsertList = new List<ContentDocumentLink>();
        
        if(contentMapList.size() != 0) {
            Map<String,Inbound_Document__mdt> inboundDocMap = new Map<String,Inbound_Document__mdt>();
            for(Inbound_Document__mdt inboundDoc : getMatterCreateInboundDocs()) {
                inboundDocMap.put(inboundDoc.Document_Name__c, inboundDoc);
            }
            
            contentWrapper contentPack = contentMapList.get(0);
            if(inboundDocMap.containsKey(contentPack.docType)) {
                /*Matter__c matterRec = new Matter__c();
                MatterRec.MatterType__c = inboundDocMap.containsKey(contentPack.docType) ? inboundDocMap.get(contentPack.docType).Document_Type__c : Null;
                //Claim Number not provided
                if(claimId == dummyClaimId) {
                	matterRec.OwnerId = CommonUtility.getQueueByName().get(Constants_AC.queue_ALJ_Clerk).Id;
                }
                else {
                    matterRec.OwnerId = CommonUtility.getQueueByName().get(Constants_AC.queue_Chief_ALJ).Id;
                    matterRec.ClaimNumber__c = claimId;
                }
                insert matterRec;*/
                
                Related_Doc__c relDoc = new Related_Doc__c();
                //relDoc.ALJCaseNumber__c = matterRec.Name;
                //relDoc.Related_Matter_Id__c = matterRec.Id;
                relDoc.ICA_Claim_Number__c = claimNo != Null ? claimNo : Null;
                relDoc.RecordTypeId = CommonUtility.getRecordTypeByName().get('DocumentCommon').Id;
                relDoc.Document_Type__c = inboundDocMap.containsKey(contentPack.docType) ? inboundDocMap.get(contentPack.docType).Document_Type__c : Null;
                relDoc.Received_Date__c = System.now();
                relDoc.Is_Community_Record__c = true;
                relDoc.OwnerId = CommonUtility.getQueueByName().get(Constants_AC.queue_ALJ_Division_WG).Id;
                //ICA-5123 - New field on community when users upload Vexatious Litigant Motion
				if(relDoc.Document_Type__c == Constants_AC.matter_Type_Vex && contentPack.relClaims != Null) {
                	relDoc.Related_Claims__c = contentPack.relClaims;
                }
                insert relDoc;
                
                /*List<ContentDocument> contentDocumentList = [SELECT Id,LatestPublishedVersion.versionData,LatestPublishedVersion.FileType,LatestPublishedVersion.Title FROM ContentDocument WHERE Id =: contentPack.Id];
				System.debug('contentDocumentList : '+contentDocumentList);*/
                
                List<ContentDocumentLink> contentDocumentList = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: contentPack.Id AND LinkedEntityId =: claimId];
                System.debug('contentDocumentList : '+contentDocumentList);
                
                if(contentDocumentList.size() != 0) {
                    /*ContentDocument contentFile = contentDocumentList.get(0);
                    Attachment mainAttach = createAttachment(relDoc.Id, contentFile.LatestPublishedVersion.Title, contentFile.LatestPublishedVersion.versionData, contentFile.LatestPublishedVersion.fileType);
                    insert mainAttach;*/
                    ContentDocumentLink contentLink = createContentDocument(contentDocumentList.get(0).ContentDocumentId, relDoc.Id);
                    insert contentLink;
                    
					//ICA-3565 - Civil Penalities
                    if(relDoc.Document_Type__c == Constants_AC.matter_Type_CS_RECD) {
                        List<Notification__c> notifyList = [SELECT Id,Due_Date__c,Claim_List__c,Matter__c FROM Notification__c WHERE Matter__c != Null AND Matter__r.Parent_Matter__c = Null AND Document_Type__c =: Constants_AC.Cancel_Civil_Penality AND Due_Date__c != Null AND Due_Date__c >=: System.today() ORDER BY Due_Date__c ASC];
                        List<Notification__c> validNotifyList = new List<Notification__c>();
                        List<Document__c> docList = [SELECT Id,Claim__c,Document_101__c,Document_102__c,Document_104__c,Document_107__c,Document_108__c,Document_106__c,
								Related_Doc__c,Related_Doc__r.Document_Type__c,Document_106__r.CreatedDate,Document_104__r.CreatedDate,Document_107__r.CreatedDate FROM Document__c WHERE Claim__c =: claimId];
                        Notification__c notify;
                        if(HelperClass_AC.findDocumentOnClaim(docList, 'hasDWO') && notifyList.size() != 0) {
                            for(Notification__c notifyRec : notifyList) {
                                if(notifyRec.Claim_List__c != Null && !notifyRec.Claim_List__c.contains(',') && notifyRec.Claim_List__c == claimNo) {
                                    validNotifyList.add(notifyRec);
                                }
                            }
                            if(validNotifyList.size() != 0) {
                                notify = validNotifyList.get(0);
                                notify.Due_Date__c = Null;
                                update notify;
                            }
                        }
                    }
                    
                    delete contentDocumentList;
                }
            }
        }
        return '';
    }
    //ICA-3989 - ALJ - Upload other documents from community
    //Method to submit document for creation of a matter record
    @AuraEnabled
    public static String submitRecordMatter(Id matterId, String claimNo, String matterNo, String content,String comment) {        
        System.debug(
            'Matter ID : '+matterId+
            'ClaimNo : '+claimNo+
            'Content : '+content+
            
            'MatterNo : '+matterNo
        );
        List<contentWrapper> contentMapList = (List<contentWrapper>)System.JSON.deserialize(content, List<contentWrapper>.class);
        
        Set<ID> contentToDeleteIDs = new Set<ID>();
        List<ContentDocumentLink> linksToInsertList = new List<ContentDocumentLink>();
        
        if(contentMapList.size() != 0) {
            Map<String,Inbound_Document__mdt> inboundDocMap = new Map<String,Inbound_Document__mdt>();
            for(Inbound_Document__mdt inboundDoc : getInboundDocs()) {
                inboundDocMap.put(inboundDoc.Document_Name__c, inboundDoc);
            }
            
            contentWrapper contentPack = contentMapList.get(0);
            if(inboundDocMap.containsKey(contentPack.docType)) {               
                
                Related_Doc__c relDoc = new Related_Doc__c();
                relDoc.Related_Matter_Id__c = matterId;
                relDoc.ALJCaseNumber__c = matterNo;
                relDoc.ICA_Claim_Number__c = claimNo != Null ? claimNo : Null;
                relDoc.RecordTypeId = CommonUtility.getRecordTypeByName().get('DocumentCommon').Id;
                relDoc.Document_Type__c = inboundDocMap.containsKey(contentPack.docType) ? inboundDocMap.get(contentPack.docType).Document_Type__c : Null;
                relDoc.Received_Date__c = System.now();
                relDoc.Is_Community_Record__c = true;
                relDoc.OwnerId = CommonUtility.getQueueByName().get(Constants_AC.queue_ALJ_Division_WG).Id;
                relDoc.Comment__c = comment;
                insert relDoc;
                
                /*List<ContentDocument> contentDocumentList = [SELECT Id,LatestPublishedVersion.versionData,LatestPublishedVersion.FileType,LatestPublishedVersion.Title FROM ContentDocument WHERE Id =: contentPack.Id];
				System.debug('contentDocumentList : '+contentDocumentList);*/
                List<ContentDocumentLink> contentDocumentList = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: contentPack.Id AND LinkedEntityId =: matterId];
                System.debug('contentDocumentList : '+contentDocumentList);
                
                if(contentDocumentList.size() != 0) {
                    /*ContentDocument contentFile = contentDocumentList.get(0);
					Attachment mainAttach = createAttachment(relDoc.Id, contentFile.LatestPublishedVersion.Title, contentFile.LatestPublishedVersion.versionData, contentFile.LatestPublishedVersion.fileType);
					insert mainAttach;*/
                    ContentDocumentLink contentLink = createContentDocument(contentDocumentList.get(0).ContentDocumentId, relDoc.Id);
                    insert contentLink;                    
                    delete contentDocumentList;
                }
                List<Matter__c> matterList = [SELECT Id,OwnerId,X1061_J__c,Claimant_First_Name__c,Claimant_Last_Name__c,Request_for_Review_Response__c,ReviewDate__c,SubStatus__c FROM Matter__c WHERE Id =: matterId];  
                if(matterList.size() != 0) {
                    Matter__c matter = matterList.get(0);
                    String Claimantname = (matter.Claimant_First_Name__c != Null ? matter.Claimant_First_Name__c : '')+' '+(matter.Claimant_Last_Name__c != Null ? matter.Claimant_Last_Name__c : '');
                    if(relDoc.Document_Type__c != Constants_AC.docTypeRH_withdrawal) {
                        List<GroupMember> groupMemberList = new  List<GroupMember>();
                        //ICA-3322 - Request for Change of Arbitrator/Judge/Affidavit
                        /*if(relDoc.Document_Type__c == Constants_AC.matter_Type_CHANGE_JU || relDoc.Document_Type__c == Constants_AC.matter_Type_REQ_CHANGE_ARB) {
                            if(HelperClassALJ_AC.getGroupMembersById(CommonUtility.getQueueByName().get(Constants_AC.queue_Chief_ALJ).Id) != Null) {
                            	groupMemberList.addAll(HelperClassALJ_AC.getGroupMembersById(CommonUtility.getQueueByName().get(Constants_AC.queue_Chief_ALJ).Id));
                            }
                        }*/
                        if(matter.OwnerId.getsObjectType() == Group.sObjectType && HelperClassALJ_AC.getGroupMembersById(matter.OwnerId) != Null) {
                            groupMemberList.addAll(HelperClassALJ_AC.getGroupMembersById(matter.OwnerId));
                        }
                        if(groupMemberList.size() != 0) {
                            List<Task> lstTask = HelperClassALJ_AC.createtask(matter,Constants_AC.Uploaded_Community,groupMemberList,0);
                            for(Task taskRec : lstTask) {
                                taskRec.Description__c = contentPack.docType +' have been added. Please review.';
                                taskRec.Subject = contentPack.docType + (claimantName != Null ? '-'+' '+claimantName : Null);
                                taskRec.Task_Name__c  = contentPack.docType;
                                if(relDoc.Document_Type__c == Constants_AC.matter_Type_CHANGE_JU || relDoc.Document_Type__c == Constants_AC.matter_Type_REQ_CHANGE_ARB) {
                                    taskRec.RecordTypeId = CommonUtility.getRecordTypeByName().get(Constants_AC.recType_Change_of_Judge).Id;
                                    taskRec.Subject = Constants_AC.Change_of_Judge_Affidavit  + (claimantName != Null ? '-'+' '+claimantName : Null);
                                    taskRec.Task_Name__c = Constants_AC.Change_of_Judge_Affidavit;
                                    taskRec.Description__c = Constants_AC.Change_of_Judge_Affidavit+' have been added. Please review.';
                                }
                            }
                            
                            system.debug('contentPack.docType'+contentPack.docType);
                            if(contentPack.docType == Constants_AC.Request_for_Review || contentPack.docType == Constants_AC.j_Response_docType) {
                                List<Notification__c> notifyList = new List<Notification__c>();
                                notifyList = [SELECT Id,Due_Date__c,Claim_List__c,Matter__c FROM Notification__c WHERE Matter__c =: matter.ID AND Matter__r.Parent_Matter__c = Null AND (Document_Type__c =: Constants_AC.Decision_Hearing_DocType OR Document_Type__c =: Constants_AC.j_Investigation_API) AND Due_Date__c != Null AND Due_Date__c >=: System.today() ORDER BY Due_Date__c ASC];
                                if(notifyList != Null) {
                                    for(Notification__c noti : notifyList) {
                                        noti.Due_Date__c = Null;
                                    }
                                } 
                                if(contentPack.docType == Constants_AC.Request_for_Review) {
                                    if(!matter.Request_for_Review_Response__c) {
                                    	matter.Request_for_Review_Response__c = True;
                                    }
                                }
                                if(contentPack.docType == Constants_AC.j_Response_docType) {
                                    matter.J_Response_Received__c = TRUE;  
                                    lstTask.addAll(HelperClassALJ_AC.createtask(matter,Constants_AC.task_1061J_assigned,groupMemberList,Null));    
                                }
                                update notifyList;
                            }
                            if(contentPack.docType == Constants_AC.Request_for_Review) {
                                matter.ReviewDate__c = system.now();
                            }
                            if(relDoc.Document_Type__c == Constants_AC.Cancel_Civil_Penality_Withdrawal) {
                                List<Claim__c> claimList = [SELECT Id,Name FROM Claim__c WHERE Name =: claimNo LIMIT 1];
                                if(claimList.size() != 0) {
                                    List<Document__c> docList = [SELECT Id,Claim__c,Document_101__c,Document_102__c,Document_104__c,Document_107__c,Document_108__c,Document_106__c,
											Related_Doc__c,Related_Doc__r.Document_Type__c,Document_106__r.CreatedDate,Document_104__r.CreatedDate,Document_107__r.CreatedDate FROM Document__c WHERE Claim__c =: claimList.get(0).Id];
                                    List<Notification__c> notifyList = [SELECT Id,Due_Date__c,Claim_List__c,Matter__c FROM Notification__c WHERE Matter__c =: matter.Id AND Matter__r.Parent_Matter__c = Null AND Document_Type__c =: Constants_AC.Cancel_Civil_Penality AND Due_Date__c != Null AND Due_Date__c >=: System.today() ORDER BY Due_Date__c ASC LIMIT 1];
                                    if(HelperClass_AC.findDocumentOnClaim(docList, 'hasCSRECD') && notifyList != Null) {
                                        for(Notification__c noti : notifyList) {
                                            noti.Due_Date__c = Null;
                                        }
                                        update notifyList;
                                    }
                                }
                            }
                            if(relDoc.Document_Type__c == Constants_AC.matter_Request_for_Review_Response) {
                                matter.SubStatus__c = Constants_AC.matter_SubStatus_Decision;
                            }
                            if(lstTask.size() > 0) {
                                insert lstTask;
                            }
                        }
                    }
                    update matter;
                }               
            }
        }
        return '';
    }
    
    //Wrapper class for storing Content information 
    public class contentWrapper {
        public String Id;
        public String doc;
        public String docType;
        public String fileName;
        public String relClaims;
    }
    
    //Method to create a new content link between document and its parent
    public static ContentDocumentLink createContentDocument(Id contentId, Id parentId) {
        ContentDocumentLink link = new ContentDocumentLink();
        link.Visibility = 'AllUsers';
        link.ShareType = 'V';
        link.ContentDocumentId = contentId;
        link.LinkedEntityId = parentId;
        return link;
    }
    /*
public static Attachment createAttachment(Id parentId, String fileName, Blob body, String contentType) {
Attachment attach = new Attachment();
attach.parentId = parentId;
attach.Body = body;
attach.Name = fileName;
attach.ContentType = contentType;
return attach;
}*/
}