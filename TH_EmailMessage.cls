/**
 * @author Comforth Dev Team
 * @date 17/12/2020
 * @group Trigger Handler
 * @description Trigger Handler for EmailMessage Object
 */
 public without sharing class TH_EmailMessage extends TH_TriggerHandler {

    //@IMPORTANT: SOBJ_NAME must always be declared first
    private static final String SOBJ_NAME = Constants.OBJ_API_EMAILMESSAGE;
    public static Set<String> setBypassMethods = new Set<String>();

    /**
    * @author 
    * @date 
    * @description Constructor
    * @return void
    */
    public TH_EmailMessage() {
    }
    
    
    /**
    * @author  Comforth dev team
    * @date 
    * @description Handler Method for Before Insert Event
    * @return void
    */
    public override void beforeInsert() {
        
        //Get Bypassed Methods from Custom MetaData
        setBypassMethods = (TH_TriggerHandler.bypassMethodsMap != null && TH_TriggerHandler.bypassMethodsMap.containsKey(SOBJ_NAME)) 
                           ? TH_TriggerHandler.bypassMethodsMap.get(SOBJ_NAME) :new Set<String>();

        //system.debug('@BEFORE_INSERT - METHODS TO BE BYPASSED: ' + setBypassMethods);


        List<EmailMessage> listEmailMessage = new List<EmailMessage>();

		// Loop
        for(EmailMessage newEM : (List<EmailMessage>) Trigger.new){ 
            if(!setBypassMethods.contains('copyClosedCase')) {
				listEmailMessage.add(newEM);
			}
        }		
        

        if(!listEmailMessage.isEmpty()) {
			SM002_EmailMessage.copyClosedCase(listEmailMessage);
		}
                
    }

    /**
    * @author  Comforth dev team
    * @date 
    * @description Handler Method for Before Insert Event
    * @return void
    */
    public override void beforeUpdate() {
        
        //system.debug('BEFORE UPDATE');
                
    }

}