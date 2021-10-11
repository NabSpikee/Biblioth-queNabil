/**
  * @author Comforth Dev Team
 * @date 23.05.2019
 * @group Trigger Handler
 * @description Trigger Handler for Case Object
 */
public without sharing class TH_Case extends TH_TriggerHandler {

    //@IMPORTANT: SOBJ_NAME must always be declared first
    private static final String SOBJ_NAME = Constants.OBJ_API_CASE;
    public static Set<String> setBypassMethods = new Set<String>();

    /**
    * @author 
    * @date 
    * @description Constructor
    * @return void
    */
    public TH_Case() {
    }
    
    /**
    * @author  Comforth dev team
    * @date 
    * @description Handler Method for Before Insert Event
    * @return void
    */
    public override void beforeUpdate() {
        
        system.debug('BEFORE UPDATE');
        
        //Get Bypassed Methods from Custom MetaData
        setBypassMethods = (TH_TriggerHandler.bypassMethodsMap != null && TH_TriggerHandler.bypassMethodsMap.containsKey(SOBJ_NAME)) 
            ? TH_TriggerHandler.bypassMethodsMap.get(SOBJ_NAME) :new Set<String>();

        system.debug('@BEFORE_INSERT - METHODS TO BE BYPASSED: ' + setBypassMethods);


        // Loop

        Map<Id,Case> mapCaseAlRdTypeCaseSubtype = new Map<Id,Case>();

        for(Case cs : (List<Case>) Trigger.new) { 
            if(
                !setBypassMethods.contains('AlignmentRecordtypeSubtype') && 
                cs.RecordTypeId != ((Map<Id, Case>) Trigger.oldMap).get(cs.Id).RecordTypeId 
            ) {
                mapCaseAlRdTypeCaseSubtype.put(cs.Id,cs);

                system.debug('mapCaseAlRdTypeCaseSubtype'+mapCaseAlRdTypeCaseSubtype );
            }
        }      
        if(!mapCaseAlRdTypeCaseSubtype.isEmpty()) {
            SM004_Case.AlignmentRecordtypeSubtypes((Map<Id, Case>) Trigger.oldMap, mapCaseAlRdTypeCaseSubtype);
        }
    }

    
}