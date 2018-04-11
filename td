
RightNow.Widgets.ConditionalChatLink=RightNow.Widgets.extend({constructor:function()
{this._container=this.Y.one(this.baseSelector);this._isPersistentChat=this.data.attrs.is_persistent_chat;this._linkClicked=false;this._pollingBegan=null;this._offerRecorded=this.data.js.offer_recorded;this._queueReceivedEventSubscribed=false;this._linkUrl=this.data.js.link_url;this._eeWidgetId=null;this._offered=false;if(this.data.attrs.is_persistent_chat)
{this._ls=RightNow.Chat.LS;if(!this._ls.isSupported)
{this._isPersistentChat=false;}}
var initialResult={};if(this.data.attrs.initiate_by_event)
{if(this.data.attrs.hide_on_unavailable)
{initialResult.stats={availableSessionCount:0,expectedWaitSeconds:0};}}
else if(this.data.js.unavailable_hours)
{initialResult.out_of_hours=true;}
else if(this.data.js.available_session_count!==undefined&&this.data.js.expected_wait_seconds!==undefined)
{initialResult.stats={availableSessionCount:this.data.js.available_session_count,expectedWaitSeconds:this.data.js.expected_wait_seconds};}
this._eo=new RightNow.Event.EventObject(this,{data:{wait_threshold:this.data.attrs.wait_threshold,min_agents_avail:this.data.attrs.min_sessions_avail,interface_id:this.data.js.interface_id,contact_email:this.data.js.contact_email,contact_fname:this.data.js.contact_fname,contact_lname:this.data.js.contact_lname,prod:this.data.js.prod,cat:this.data.js.cat,c_id:this.data.js.c_id,org_id:this.data.js.org_id,cacheable:true,avail_type:this.data.js.avail_type,ccl:true,name:'ConditionalChatLink'}});this._onQueueReceived(initialResult);RightNow.Event.subscribe("evt_productCategoryFilterSelected",this._onProdCatChanged,this);if(!this.data.attrs.initiate_by_event&&this.data.attrs.enable_availability_check&&this.data.attrs.enable_polling)
this._startPollingTimer(false);if(this.data.attrs.initiate_by_event)
{RightNow.Event.subscribe("evt_customInitialization",this._startPollingTimer,this,true);RightNow.Event.fire("evt_CCLReady");RightNow.Event.subscribe("evt_isCCLReady",function(){RightNow.Event.fire("evt_CCLReady");},this);}},_generateEncodedChatData:function(args)
{var chatData=this.data.js.routeData||'';if(args!==undefined&&args[0]!==undefined&&args[0].data!==undefined)
{var data=args[0].data;this._eeWidgetId=data.instance_id;chatData=this._addChatDataParam(chatData,'referrerUrl',encodeURIComponent(window.location.href));chatData=this._addChatDataParam(chatData,'v_id',data.visitor_id);chatData=this._addChatDataParam(chatData,'ee_id',data.ee_id);chatData=this._addChatDataParam(chatData,'es_id',data.estara_id);chatData=this._addChatDataParam(chatData,'ee_s_id',data.ee_session_id);}
chatData=this._addChatDataParam(chatData,'hash',new Date().getTime()+Math.random().toString(36).substring(7));return RightNow.Text.Encoding.base64Encode(chatData);},_startPollingTimer:function(startImmediately,args)
{var chatData=this._generateEncodedChatData(args);if(chatData.length!==0)
this._linkUrl=RightNow.Url.addParameter(this._linkUrl,'chat_data',chatData);if(this._pollingBegan!==null&&this.data.attrs.enable_polling)
return;if(!this._queueReceivedEventSubscribed)
RightNow.Event.subscribe("evt_chatQueueResponseCCL",this._onQueueReceived,this);this._pollingBegan=new Date().getTime();if(startImmediately)
{this._onPollingTimerElapsed();}
else
{this.Y.later(12000,this,this._onPollingTimerElapsed);}},_onPollingTimerElapsed:function()
{if(RightNow.Event.fire("evt_chatQueueRequest",this._eo))
{RightNow.Ajax.makeRequest(this.data.attrs.get_chat_info_ajax,this._eo.data,{successHandler:this._onQueueReceived,failureHandler:function(){},scope:this,json:true,data:this._eo,type:"GETPOST",cors:true});}
var timeElapsed=new Date().getTime()-this._pollingBegan;var newTimeout=timeElapsed>=300000?60000:12000;if(this.data.attrs.enable_polling)
this.Y.later(newTimeout,this,this._onPollingTimerElapsed);},_openChatLink:function()
{var callback=null;if(this.data.attrs.open_in_new_window)
window.open(this._linkUrl,'chatLauncher','width='+this.data.attrs.chat_login_page_width+',height='+this.data.attrs.chat_login_page_height+',scrollbars=1,resizable=1');else
callback=function(){window.location.href=this._linkUrl;};if(!this._linkClicked)
{this._linkClicked=true;this._publishStats({w:this.data.js.dqaWidgetType.toString(),accepts:1},callback);}
var eo=new RightNow.Event.EventObject(this,{data:{id:this._eeWidgetId,name:'ConditionalChatLink'}});RightNow.Event.fire("evt_CCLChatAccepted",eo);},_onQueueReceived:function(result)
{if(result&&result.out_of_hours)
{this._container.setContent(this.Y.Node.create(new EJS
({text:this.getStatic().templates.unavailableHoursMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_unavailable_hours})));this._addClickHandler(this.Y.one(this.baseSelector+'_UnavailableHoursLink'));}else if(result&&result.stats&&RightNow.Event.fire("evt_chatQueueResponse",{data:{w_id:this._eo.w_id,name:"ConditionalChatLink"},response:{stats:{expectedWaitSeconds:parseInt(result.stats.expectedWaitSeconds,10)}}}))
{var availableSessionCount=0,expectedWaitSeconds=0;var availableImmediately=false,availableWithWait=false,unavailableBusy=false,unavailableHours=false;if(result===null||result===undefined){result={};}
var eoData=this._eo.data;this._linkUrl=eoData.prod?RightNow.Url.addParameter(this._linkUrl,'p',eoData.prod):RightNow.Url.deleteParameter(this._linkUrl,'p');this._linkUrl=eoData.cat?RightNow.Url.addParameter(this._linkUrl,'c',eoData.cat):RightNow.Url.deleteParameter(this._linkUrl,'c');if(result.stats)
{availableSessionCount=parseInt(result.stats.availableSessionCount,10);expectedWaitSeconds=parseInt(result.stats.expectedWaitSeconds,10);if(expectedWaitSeconds<=this.data.attrs.wait_threshold&&availableSessionCount>=this.data.attrs.min_sessions_avail&&(expectedWaitSeconds>0||availableSessionCount>0))
{if(expectedWaitSeconds===0)
availableImmediately=true;else
availableWithWait=true;}
else
{unavailableBusy=true;}}
else if(result.out_of_hours)
{unavailableHours=true;}
this._container.removeClass('');if(this.data.attrs.hide_on_unavailable&&(unavailableHours||unavailableBusy))
{this._container.addClass('');}
else if(availableImmediately||availableWithWait)
{if(!this._offerRecorded)
{this._offerRecorded=true;this._publishStats({w:this.data.js.dqaWidgetType.toString(),offers:1},null);}
if(availableImmediately)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.availableImmediatelyMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this._parseMacro(this.data.attrs.label_available_immediately_template,expectedWaitSeconds)})));if(this._isPersistentChat)
{this.data.attrs.enable_polling=false;this._addPersistentChatClickHandler(this.Y.one(this.baseSelector+'_AvailableImmediatelyLink'));}
else
{this._addClickHandler(this.Y.one(this.baseSelector+'_AvailableImmediatelyLink'));}}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.availableWithWaitMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this._parseMacro(this.data.attrs.label_available_with_wait_template,expectedWaitSeconds)})));if(this._isPersistentChat)
{this.data.attrs.enable_polling=false;this._addPersistentChatClickHandler(this.Y.one(this.baseSelector+'_AvailableWithWaitLink'));}
else
{this._addClickHandler(this.Y.one(this.baseSelector+'_AvailableWithWaitLink'));}}
if(!this._offered)
{this._offered=true;var eo=new RightNow.Event.EventObject(this,{data:{id:this._eeWidgetId,name:'ConditionalChatLink'}});RightNow.Event.fire("evt_CCLChatOffered",eo);}}
else if(unavailableBusy)
{if(this._isPersistentChat)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.persistentMessage}).render({instanceID:this.instanceID,message:this._parseMacro(this.data.attrs.label_unavailable_busy_template,expectedWaitSeconds)})));}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.unavailableBusyMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this._parseMacro(this.data.attrs.label_unavailable_busy_template,expectedWaitSeconds)})));this._addClickHandler(this.Y.one(this.baseSelector+'_UnavailableBusyLink'));}}
else if(unavailableHours)
{if(this._isPersistentChat)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.persistentMessage}).render({instanceID:this.instanceID,message:this._parseMacro(this.data.attrs.label_unavailable_hours)})));}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.unavailableHoursMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_unavailable_hours})));this._addClickHandler(this.Y.one(this.baseSelector+'_UnavailableHoursLink'));}}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.defaultMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_default})));this._addClickHandler(this.Y.one(this.baseSelector+'_DefaultLink'));}}
else if(!this.data.attrs.enable_availability_check)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.defaultMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_default})));this._addClickHandler(this.Y.one(this.baseSelector+'_DefaultLink'));}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.unavailableMessage}).render({instanceID:this.instanceID,message:this.data.attrs.label_unavailable})));}},_addPersistentChatClickHandler:function(elementNode){elementNode.on('click',this._launchPersistentChat,this);},_launchPersistentChat:function(){RightNow.UI.hide(this.Y.one(this.baseSelector+'.rn_ConditionalChatLink'));RightNow.Event.fire("evt_launchPersistentChat",{});},_addClickHandler:function(elementNode)
{if(elementNode)
{elementNode.on('click',this._openChatLink,this);}},_parseMacro:function(message,expectedWaitSeconds)
{var expectedWaitMinutes=Math.floor(expectedWaitSeconds/60);if(message.indexOf('{NUM_MINUTES}'!==-1))
{expectedWaitSeconds=expectedWaitSeconds%60;message=message.replace('{NUM_MINUTES}',expectedWaitMinutes).replace('{MINUTES}',expectedWaitMinutes===1?RightNow.Interface.getMessage("MINUTE_LC_LBL"):RightNow.Interface.getMessage('MINUTES_LWR_LBL'));}
var expectedWaitSecondsPadded=expectedWaitSeconds<10?'0'+expectedWaitSeconds.toString():expectedWaitSeconds;message=message.replace('{TIME}',expectedWaitMinutes+':'+expectedWaitSecondsPadded);return message.replace('{NUM_SECONDS}',expectedWaitSeconds).replace('{SECONDS}',expectedWaitSeconds===1?RightNow.Interface.getMessage('SECOND_LBL'):RightNow.Interface.getMessage('SECONDS_LC_LBL'));},_publishStats:function(data,callback)
{RightNow.Ajax.CT.submitAction(RightNow.Ajax.CT.WIDGET_STATS,data,callback,this);},_addChatDataParam:function(chatData,key,value)
{if(chatData===undefined)
chatData='';if(value===undefined||value.length===0)
return chatData;if(chatData.length!==0)
chatData+='&';chatData+=key+'='+value;return chatData;},_onProdCatChanged:function(type,args)
{var prodCatType=args[0].data.data_type;var value=args[0].data.value;if(prodCatType.indexOf("Category")>-1)
this._eo.data.cat=value;else
this._eo.data.prod=value;}});
RightNow.Widgets.FormSubmit=RightNow.Form.extend({overrides:{constructor:function(){this.parent();this.inputDataChanged=false;this._navigateToUrlFlag=false;this._formButton=this.Y.one(this.baseSelector+"_Button");this._formSubmitFlag=this.Y.one(this.baseSelector+"_Submission");if(!this._formButton||!this._formSubmitFlag)return;if(this._formSubmitFlag.get("checked")){this._formButton.set("disabled","true");return;}
this.on("validation:fail",this._onFormValidationFail,this).on("validation:fail",this._resetFormButton,this,false).on("validation:pass",this._onFormValidated,this).on("response",this._defaultFormSubmitResponse,this).on("response",this._resetFormButton,this).on("submitRequest",this._onButtonClick,this).on("reset",this._resetFormForSubmission,this).on("responseError",this._onErrorResponse,this).on("formUpdated",this._onFormUpdated,this);this._toggleClickListener(true);RightNow.Event.subscribe("evt_formToggleButton",function(type,args){this._toggleClickListener(args[0]);},this);RightNow.Event.subscribe("evt_formInputDataChanged",function(){this.inputDataChanged=true;},this);if(this.data.attrs.unsaved_data_dialog){var that=this;window.onbeforeunload=function(e){if(that.inputDataChanged){return"";}};}}},_onButtonClick:function(evt){this.inputDataChanged=false;if(evt&&evt.halt){evt.halt();}
if(this._requestInProgress)return false;this._toggleClickListener(false);this._removeFormErrors();if(this.Y.UA.ie&&window.external&&"AutoCompleteSaveForm"in window.external){window.external.AutoCompleteSaveForm(document.getElementById(this._parentForm));}
this._fireSubmitRequest();},_fireSubmitRequest:function(){var eo=new RightNow.Event.EventObject(this,{data:{form:this._parentForm,f_tok:this.data.js.f_tok,error_location:this._errorMessageDiv.get("id"),timeout:this.data.attrs.timeout*1000}});RightNow.Event.fire("evt_formButtonSubmitRequest",eo);this.fire("collect",eo);},_onFormValidated:function(){this._toggleLoadingIndicators(true);this.fire("send",this.getValidatedFields());},_onFormValidationFail:function(){this._displayErrorMessages(this._errorMessageDiv);RightNow.Event.fire("evt_formValidateFailure",new RightNow.Event.EventObject(this));},_clearFlashData:function(){var infoDiv=this.Y.one('.rn_MessageBox.rn_InfoMessage');if(infoDiv){var parentClass=infoDiv.ancestor().getAttribute('class');if(parentClass&&parentClass.search("rn_SmartAssistantDialog")===-1)
infoDiv.set('innerHTML','').removeClass('rn_InfoMessage');}},_absoluteOffset:function(element){var top=0;do{top+=element.get('offsetTop');element=element.get('offsetParent');}
while(element);return top;},_displayErrorMessages:function(messageArea){messageArea.addClass("rn_MessageBox").addClass("rn_ErrorMessage").removeClass("rn_Hidden");this._clearFlashData();if(!this.Y.DOM.inViewportRegion(this.Y.Node.getDOMNode(messageArea),true)){(new this.Y.Anim({node:this.Y.one(document.body),to:{scrollTop:this._absoluteOffset(messageArea)-40},duration:0.5})).run();}
var firstField=messageArea.one("a");if(firstField){firstField.focus();firstField.setAttribute('role','alert');messageArea.removeAttribute('tabIndex');}
else{messageArea.set('tabIndex',0);messageArea.setAttribute('role','alert');messageArea.focus();}
var errorLbl=messageArea.all("div").size()>1?RightNow.Interface.getMessage("ERRORS_LBL"):RightNow.Interface.getMessage("ERROR_LBL");messageArea.prepend("<h2>"+errorLbl+"</h2>");messageArea.one("h2").setAttribute('role','alert');},_defaultFormSubmitResponse:function(type,args){if(this.fire('defaultResponseHandler',args[0])){this._formSubmitResponse(type,args);}},_formSubmitResponse:function(type,args){var responseObject=args[0].data,result;if(!this._handleFormResponseFailure(responseObject)&&responseObject.result){result=responseObject.result;if(!result.sa){if(result.transaction||result.redirectOverride){return this._handleFormResponseSuccess(result);}
else{this._displayErrorDialog();}}}
args[0].data||(args[0].data={});args[0].data.form=this._parentForm;RightNow.Event.fire('evt_formButtonSubmitResponse',args[0]);},_handleFormResponseSuccess:function(result){this._formSubmitFlag.set("checked",true);if(this.data.attrs.label_on_success_banner){RightNow.UI.displayBanner(this.data.attrs.label_on_success_banner,{focusElement:this._formButton}).on('close',function(){this._confirmOnNavigate(result);},this);return;}
this._confirmOnNavigate(result);},_handleFormResponseFailure:function(responseObject){if(!responseObject){this._displayErrorDialog(RightNow.Interface.getMessage("THERE_PROB_REQ_ACTION_COULD_COMPLETED_MSG"));return true;}
if(responseObject.errors){var errorMessage="";this.Y.Array.each(responseObject.errors,function(error){errorMessage+="<div><b>"+error.externalMessage+"</b></div>";});this._errorMessageDiv.append(errorMessage);this._onFormValidationFail();return true;}
if(!responseObject.result){this._displayErrorDialog();return true;}
return false;},_navigateToUrl:function(result){var url;if(result.redirectOverride){url=result.redirectOverride+result.sessionParam;}
else if(this.data.attrs.on_success_url){var paramsToAdd='';this.Y.Object.each(result.transaction,function(details){if(details.key){paramsToAdd+='/'+details.key+'/'+details.value;}});if(paramsToAdd){url=this.data.attrs.on_success_url+paramsToAdd+result.sessionParam;}
else{var sessionValue=result.sessionParam.substr(result.sessionParam.lastIndexOf("/")+1);if(!sessionValue&&this.data.js.redirectSession)
sessionValue=this.data.js.redirectSession;url=RightNow.Url.addParameter(this.data.attrs.on_success_url,'session',sessionValue);}}
else{url=window.location+result.sessionParam;}
RightNow.Url.navigate(url+this.data.attrs.add_params_to_url);},_confirmOnNavigate:function(result){if(this.data.attrs.on_success_url!=='none'){if(this.data.attrs.label_confirm_dialog!==''){RightNow.UI.Dialog.messageDialog(this.data.attrs.label_confirm_dialog,{exitCallback:{fn:function(){this._navigateToUrl(result);},scope:this},width:'250px'});}
else{if(this.Y.Lang.trim(this.data.attrs.on_success_url)!==''){this._navigateToUrlFlag=true;}
this._navigateToUrl(result);}}},_resetFormForSubmission:function(){this._navigateToUrlFlag=false;this._removeFormErrors();this._resetFormButton();},_onFormUpdated:function(){if(this._errorMessageDiv.all('[data-field]').size()===0){this._errorMessageDiv.addClass("rn_Hidden").set("innerHTML","");}},_onErrorResponse:function(response){this._displayErrorDialog(response.suggestedErrorMessage||RightNow.Interface.getMessage("THERE_PROB_REQ_ACTION_COULD_COMPLETED_MSG"));this._resetFormButton();},_resetFormButton:function(){if(this._navigateToUrlFlag){return;}
this._toggleLoadingIndicators(false);this._toggleClickListener(true);},_removeFormErrors:function(){this._errorMessageDiv.addClass("rn_Hidden").setHTML("");},_displayErrorDialog:function(message){RightNow.UI.Dialog.messageDialog(message||RightNow.Interface.getMessage('ERROR_PAGE_PLEASE_S_TRY_MSG'),{icon:"WARN"});},_toggleLoadingIndicators:function(turnOn){this._formButton.setHTML((turnOn)?this.data.attrs.label_submitting_message:this.data.attrs.label_button).toggleClass('rn_Loading',turnOn);},_toggleClickListener:function(enable){if(this.Y.UA.ie){this._formButton.set("disabled",false);this.Y.one(this.baseSelector+" button").toggleClass("rn_IeFormButton",!enable);}
else{this._formButton.set("disabled",!enable);}
this._requestInProgress=!enable;this.Y.Event[((enable)?"attach":"detach")]("click",this._onButtonClick,this._formButton,this);}});
RightNow.Widgets.SelectionInput=RightNow.Field.extend({overrides:{constructor:function(){if(this.data.js.readOnly)return;this.parent();var attrs=this.data.attrs;this.input=(this.data.js.type==="Boolean"&&!attrs.display_as_checkbox)?this.Y.all(this._inputSelector+"_1, "+this._inputSelector+"_0"):this.Y.one(this._inputSelector);if(!this.input)return;if(attrs.hint&&!attrs.hide_hint&&!attrs.always_show_hint){this._initializeHint();}
if(attrs.initial_focus&&this.input){if(this.data.js.type==="Boolean"&&this.input[0]&&this.input[0].focus)
this.input[0].focus();else if(this.input.focus)
this.input.focus();}
if(attrs.validate_on_blur&&attrs.required){this.Y.Event.attach('blur',this.blurValidate,this.input instanceof this.Y.NodeList?this.input.item(1):this.input,this);}
this.input.on('change',function(){RightNow.Event.fire("evt_formInputDataChanged",null);this.fire('change',this);},this);this.on("constraintChange",this.constraintChange,this);var fieldName=this.data.js.name;if(fieldName==="Contact.Address.Country"){this.input.on("change",this.countryChanged,this);if(this.input.get('value'))
this.countryChanged();}
else if(fieldName==="Contact.Address.StateOrProvince"){this.currentState=this.input.get('value');RightNow.Event.on("evt_provinceResponse",this.onProvinceResponse,this);}
else if(fieldName==='Incident.StatusWithType.Status'){this.on('change',this.onStatusChanged,this);}
this.parentForm().on("submit",this.onValidate,this);}},swapLabel:function(container,requiredness,label,template){this.Y.augment(this,RightNow.RequiredLabel);var templateObject={label:label,instanceID:this.instanceID,fieldName:this._fieldName,required:requiredness,hint:this.data.attrs.hint};container.setHTML('');container.append(new EJS({text:template}).render(templateObject));},constraintChange:function(evt,constraint){constraint=constraint[0];if(constraint.required===this.data.attrs.required)return;this.toggleErrorIndicator(false);if(this.data.attrs.required&&this.lastErrorLocation){this.Y.one('#'+this.lastErrorLocation).all("[data-field='"+this._fieldName+"']").remove();}
if(this.data.attrs.label_input){if(this.data.js.type==='Boolean'&&!this.data.attrs.display_as_checkbox){this.swapLabel(this.Y.one(this.baseSelector+'_Label'),constraint.required,this.data.attrs.label_input,this.getStatic().templates.legend);}
else{this.swapLabel(this.Y.one(this.baseSelector+'_LabelContainer'),constraint.required,this.data.attrs.label_input,this.getStatic().templates.label);}}
this.data.attrs.required=constraint.required;},onValidate:function(type,args){var eo=this.createEventObject(),errors=[];this.toggleErrorIndicator(false);if(!this.validate(errors)){this.lastErrorLocation=args[0].data.error_location;this.displayError(errors,this.lastErrorLocation);RightNow.Event.fire("evt_formFieldValidationFailure",eo);return false;}
RightNow.Event.fire("evt_formFieldValidationPass",eo);return eo;},displayError:function(errors,errorLocation){var commonErrorDiv=this.Y.one("#"+errorLocation);if(commonErrorDiv){for(var id=((this.input instanceof this.Y.NodeList)?this.input.item(0).get("id"):this.input.get("id")),i=0,message;i<errors.length;i++){message=errors[i];message=(message.indexOf("%s")>-1)?RightNow.Text.sprintf(message,this.data.attrs.label_input):this.data.attrs.label_input+" "+message;commonErrorDiv.append("<div data-field=\""+this._fieldName+"\"><b><a href='javascript:void(0);' onclick='document.getElementById(\""+id+"\").focus(); return false;'>"+message+"</a></b></div>");}}
this.toggleErrorIndicator(true);},toggleErrorIndicator:function(showOrHide){var method=((showOrHide)?"addClass":"removeClass");this.input[method]("rn_ErrorField");this.Y.one(this.baseSelector+"_Label")[method]("rn_ErrorLabel");},blurValidate:function(){this.toggleErrorIndicator(!this.getValue());},countryChanged:function(){var value=this.input.get("value"),fireResponse=function(response,eventObject){RightNow.Event.fire("evt_provinceResponse",response,eventObject);};if(value){var eventObject=new RightNow.Event.EventObject(this,{data:{country_id:value}});if(RightNow.Event.fire("evt_provinceRequest",eventObject)){this._provinces=this._provinces||{};if(this._provinces[value]){return fireResponse(this._provinces[value],eventObject);}
RightNow.Ajax.makeRequest("/ci/ajaxRequestMin/getCountryValues",eventObject.data,{successHandler:function(response){this._provinces[value]=response;fireResponse(response,eventObject);},scope:this,json:true,type:"GETPOST"});}}
else{fireResponse({ProvincesLength:0,Provinces:{}});}},onProvinceResponse:function(type,args){var response=args[0],options='',provinces=response.Provinces,i,length;this.input.set("innerHTML","");if(provinces){if(!this.Y.Lang.isArray(provinces)){var temp=[];this.Y.Object.each(provinces,function(val){temp.push(val);});provinces=temp;}
if(!provinces[0]||(provinces[0].Name!=="--"&&!this.data.hideEmptyOption)){provinces.unshift({Name:"--",ID:""});}
for(i=0,length=provinces.length;i<length;i++){options+="<option value='"+provinces[i].ID+"'>"+provinces[i].Name+"</option>";}
this.input.append(options);this.input.set('value',this.currentState);}
this.currentState='';},onStatusChanged:function(){var threadInput=this.parentForm().findField('Incident.Threads');if(threadInput){threadInput.setConstraints({required:this.input.get('value')==='0'});}}});
RightNow.namespace('Custom.Widgets.widget.CustomConditionalChatLink');Custom.Widgets.widget.CustomConditionalChatLink=RightNow.Widgets.ConditionalChatLink.extend({overrides:{constructor:function(){this._container=this.Y.one(this.baseSelector);this._isPersistentChat=this.data.attrs.is_persistent_chat;this._pollingBegan=null;this._linkClicked=false;this._offerRecorded=this.data.js.offer_recorded;this._queueReceivedEventSubscribed=false;this._linkUrl=this.data.js.link_url;this._eeWidgetId=null;this._offered=false;if(this.data.attrs.is_persistent_chat)
{this._ls=RightNow.Chat.LS;if(!this._ls.isSupported)
{this._isPersistentChat=false;}}
var initialResult={};if(this.data.attrs.initiate_by_event)
{if(this.data.attrs.hide_on_unavailable)
{initialResult.stats={availableSessionCount:0,expectedWaitSeconds:0};}}
else if(this.data.js.unavailable_hours)
{initialResult.out_of_hours=true;}
else if(this.data.js.available_session_count!==undefined&&this.data.js.expected_wait_seconds!==undefined)
{initialResult.stats={availableSessionCount:this.data.js.available_session_count,expectedWaitSeconds:this.data.js.expected_wait_seconds};}
this._eo=new RightNow.Event.EventObject(this,{data:{wait_threshold:this.data.attrs.wait_threshold,min_agents_avail:this.data.attrs.min_sessions_avail,interface_id:this.data.js.interface_id,contact_email:this.data.js.contact_email,contact_fname:this.data.js.contact_fname,contact_lname:this.data.js.contact_lname,prod:this.data.js.prod,cat:this.data.js.cat,c_id:this.data.js.c_id,org_id:this.data.js.org_id,cacheable:true,avail_type:this.data.js.avail_type,ccl:true,name:'ConditionalChatLink'}});if(initialResult.stats.availableSessionCount<1){this.Y.all('.rn_ChatLaunchButton.rn_FormSubmit').remove();RightNow.UI.displayBanner(this.data.attrs.label_warning_chat_offline,{type:'INFO',});}
this.Y.all('.rn_CustomConditionalChatLink').hide();this._onQueueReceived(initialResult);RightNow.Event.subscribe("evt_productCategoryFilterSelected",this._onProdCatChanged,this);if(!this.data.attrs.initiate_by_event&&this.data.attrs.enable_availability_check&&this.data.attrs.enable_polling)
this._startPollingTimer(false);if(this.data.attrs.initiate_by_event)
{RightNow.Event.subscribe("evt_customInitialization",this._startPollingTimer,this,true);RightNow.Event.fire("evt_CCLReady");RightNow.Event.subscribe("evt_isCCLReady",function(){RightNow.Event.fire("evt_CCLReady");},this);}},_generateEncodedChatData:function(args)
{var chatData=this.data.js.routeData||'';if(args!==undefined&&args[0]!==undefined&&args[0].data!==undefined)
{var data=args[0].data;this._eeWidgetId=data.instance_id;chatData=this._addChatDataParam(chatData,'referrerUrl',encodeURIComponent(window.location.href));chatData=this._addChatDataParam(chatData,'v_id',data.visitor_id);chatData=this._addChatDataParam(chatData,'ee_id',data.ee_id);chatData=this._addChatDataParam(chatData,'es_id',data.estara_id);chatData=this._addChatDataParam(chatData,'ee_s_id',data.ee_session_id);}
chatData=this._addChatDataParam(chatData,'hash',new Date().getTime()+Math.random().toString(36).substring(7));return RightNow.Text.Encoding.base64Encode(chatData);},_startPollingTimer:function(startImmediately,args)
{var chatData=this._generateEncodedChatData(args);if(chatData.length!==0)
this._linkUrl=RightNow.Url.addParameter(this._linkUrl,'chat_data',chatData);if(this._pollingBegan!==null&&this.data.attrs.enable_polling)
return;if(!this._queueReceivedEventSubscribed)
RightNow.Event.subscribe("evt_chatQueueResponseCCL",this._onQueueReceived,this);this._pollingBegan=new Date().getTime();if(startImmediately)
{this._onPollingTimerElapsed();}
else
{this.Y.later(12000,this,this._onPollingTimerElapsed);}},_onPollingTimerElapsed:function()
{if(RightNow.Event.fire("evt_chatQueueRequest",this._eo))
{RightNow.Ajax.makeRequest(this.data.attrs.get_chat_info_ajax,this._eo.data,{successHandler:this._onQueueReceived,failureHandler:function(){},scope:this,json:true,data:this._eo,type:"GETPOST",cors:true});}
var timeElapsed=new Date().getTime()-this._pollingBegan;var newTimeout=timeElapsed>=300000?60000:12000;if(this.data.attrs.enable_polling)
this.Y.later(newTimeout,this,this._onPollingTimerElapsed);},_openChatLink:function()
{var callback=null;if(this.data.attrs.open_in_new_window)
window.open(this._linkUrl,'chatLauncher','width='+this.data.attrs.chat_login_page_width+',height='+this.data.attrs.chat_login_page_height+',scrollbars=1,resizable=1');else
callback=function(){window.location.href=this._linkUrl;};if(!this._linkClicked)
{this._linkClicked=true;this._publishStats({w:this.data.js.dqaWidgetType.toString(),accepts:1},callback);}
var eo=new RightNow.Event.EventObject(this,{data:{id:this._eeWidgetId,name:'ConditionalChatLink'}});RightNow.Event.fire("evt_CCLChatAccepted",eo);},_onQueueReceived:function(result)
{if(result&&result.out_of_hours)
{this._container.setContent(this.Y.Node.create(new EJS
({text:this.getStatic().templates.unavailableHoursMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_unavailable_hours})));this._addClickHandler(this.Y.one(this.baseSelector+'_UnavailableHoursLink'));}else if(result&&result.stats&&RightNow.Event.fire("evt_chatQueueResponse",{data:{w_id:this._eo.w_id,name:"ConditionalChatLink"},response:{stats:{expectedWaitSeconds:parseInt(result.stats.expectedWaitSeconds,10)}}}))
{var availableSessionCount=0,expectedWaitSeconds=0;var availableImmediately=false,availableWithWait=false,unavailableBusy=false,unavailableHours=false;if(result===null||result===undefined){result={};}
var eoData=this._eo.data;this._linkUrl=eoData.prod?RightNow.Url.addParameter(this._linkUrl,'p',eoData.prod):RightNow.Url.deleteParameter(this._linkUrl,'p');this._linkUrl=eoData.cat?RightNow.Url.addParameter(this._linkUrl,'c',eoData.cat):RightNow.Url.deleteParameter(this._linkUrl,'c');if(result.stats)
{availableSessionCount=parseInt(result.stats.availableSessionCount,10);expectedWaitSeconds=parseInt(result.stats.expectedWaitSeconds,10);if(expectedWaitSeconds<=this.data.attrs.wait_threshold&&availableSessionCount>=this.data.attrs.min_sessions_avail&&(expectedWaitSeconds>0||availableSessionCount>0))
{if(expectedWaitSeconds===0)
availableImmediately=true;else
availableWithWait=true;}
else
{unavailableBusy=true;}}
else if(result.out_of_hours)
{unavailableHours=true;}
this._container.removeClass('rn_Hidden');if(this.data.attrs.hide_on_unavailable&&(unavailableHours||unavailableBusy))
{this._container.addClass('rn_Hidden');}
else if(availableImmediately||availableWithWait)
{if(!this._offerRecorded)
{this._offerRecorded=true;this._publishStats({w:this.data.js.dqaWidgetType.toString(),offers:1},null);}
if(availableImmediately)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.availableImmediatelyMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this._parseMacro(this.data.attrs.label_available_immediately_template,expectedWaitSeconds)})));if(this._isPersistentChat)
{this.data.attrs.enable_polling=false;this._addPersistentChatClickHandler(this.Y.one(this.baseSelector+'_AvailableImmediatelyLink'));}
else
{this._addClickHandler(this.Y.one(this.baseSelector+'_AvailableImmediatelyLink'));}}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.availableWithWaitMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this._parseMacro(this.data.attrs.label_available_with_wait_template,expectedWaitSeconds)})));if(this._isPersistentChat)
{this.data.attrs.enable_polling=false;this._addPersistentChatClickHandler(this.Y.one(this.baseSelector+'_AvailableWithWaitLink'));}
else
{this._addClickHandler(this.Y.one(this.baseSelector+'_AvailableWithWaitLink'));}}
if(!this._offered)
{this._offered=true;var eo=new RightNow.Event.EventObject(this,{data:{id:this._eeWidgetId,name:'ConditionalChatLink'}});RightNow.Event.fire("evt_CCLChatOffered",eo);}}
else if(unavailableBusy)
{if(this._isPersistentChat)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.persistentMessage}).render({instanceID:this.instanceID,message:this._parseMacro(this.data.attrs.label_unavailable_busy_template,expectedWaitSeconds)})));}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.unavailableBusyMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this._parseMacro(this.data.attrs.label_unavailable_busy_template,expectedWaitSeconds)})));this._addClickHandler(this.Y.one(this.baseSelector+'_UnavailableBusyLink'));}}
else if(unavailableHours)
{if(this._isPersistentChat)
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.persistentMessage}).render({instanceID:this.instanceID,message:this._parseMacro(this.data.attrs.label_unavailable_hours)})));}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.unavailableHoursMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_unavailable_hours})));this._addClickHandler(this.Y.one(this.baseSelector+'_UnavailableHoursLink'));}}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.defaultMessage}).render({instanceID:this.instanceID,linkTitle:RightNow.Interface.getMessage("LIVE_CHAT_LBL"),message:this.data.attrs.label_default})));this._addClickHandler(this.Y.one(this.baseSelector+'_DefaultLink'));}}
else
{this._container.setContent(this.Y.Node.create(new EJS({text:this.getStatic().templates.unavailableMessage}).render({instanceID:this.instanceID,message:this.data.attrs.label_unavailable})));}},_addPersistentChatClickHandler:function(elementNode){elementNode.on('click',this._launchPersistentChat,this);},_launchPersistentChat:function(){RightNow.UI.hide(this.Y.one(this.baseSelector+'.rn_ConditionalChatLink'));RightNow.Event.fire("evt_launchPersistentChat",{});},_addClickHandler:function(elementNode)
{if(elementNode)
{elementNode.on('click',this._openChatLink,this);}},_parseMacro:function(message,expectedWaitSeconds)
{var expectedWaitMinutes=Math.floor(expectedWaitSeconds/60);if(message.indexOf('{NUM_MINUTES}'!==-1))
{expectedWaitSeconds=expectedWaitSeconds%60;message=message.replace('{NUM_MINUTES}',expectedWaitMinutes).replace('{MINUTES}',expectedWaitMinutes===1?RightNow.Interface.getMessage("MINUTE_LC_LBL"):RightNow.Interface.getMessage('MINUTES_LWR_LBL'));}
var expectedWaitSecondsPadded=expectedWaitSeconds<10?'0'+expectedWaitSeconds.toString():expectedWaitSeconds;message=message.replace('{TIME}',expectedWaitMinutes+':'+expectedWaitSecondsPadded);return message.replace('{NUM_SECONDS}',expectedWaitSeconds).replace('{SECONDS}',expectedWaitSeconds===1?RightNow.Interface.getMessage('SECOND_LBL'):RightNow.Interface.getMessage('SECONDS_LC_LBL'));},_publishStats:function(data,callback)
{RightNow.Ajax.CT.submitAction(RightNow.Ajax.CT.WIDGET_STATS,data,callback,this);},_addChatDataParam:function(chatData,key,value)
{if(chatData===undefined)
chatData='';if(value===undefined||value.length===0)
return chatData;if(chatData.length!==0)
chatData+='&';chatData+=key+'='+value;return chatData;},_onProdCatChanged:function(type,args)
{var prodCatType=args[0].data.data_type;var value=args[0].data.value;if(prodCatType.indexOf("Category")>-1)
this._eo.data.cat=value;else
this._eo.data.prod=value;}},methodName:function(){},renderAvailableImmediatelyMessage:function(){var content=new EJS({text:this.getStatic().templates.availableImmediatelyMessage}).render({});},renderAvailableWithWaitMessage:function(){var content=new EJS({text:this.getStatic().templates.availableWithWaitMessage}).render({});},renderDefaultMessage:function(){var content=new EJS({text:this.getStatic().templates.defaultMessage}).render({});},renderPersistentMessage:function(){var content=new EJS({text:this.getStatic().templates.persistentMessage}).render({});},renderUnavailableBusyMessage:function(){var content=new EJS({text:this.getStatic().templates.unavailableBusyMessage}).render({});},renderUnavailableHoursMessage:function(){var content=new EJS({text:this.getStatic().templates.unavailableHoursMessage}).render({});},renderUnavailableMessage:function(){var content=new EJS({text:this.getStatic().templates.unavailableMessage}).render({});}});
RightNow.Widgets.ChatLaunchButton=RightNow.Widgets.FormSubmit.extend({overrides:{constructor:function(data,instanceID,Y){this.parent();this._isProactiveChat=RightNow.Url.getParameter('pac')!==null;if(!this._parentForm||!this._formButton)return;this._addHiddenPostField('referrerUrl',this._getReferrerUrl());if(!this.data.js.showForm)
{if(!this.data.js.isBrowserSupported){Y.one('#'+this._parentForm).get('parentNode').insert(RightNow.Interface.getMessage("CHAT_SUPP_BROWSER_CHAT_AVAIL_MSG"),'before');}
RightNow.UI.hide(this._parentForm);return;}
if(RightNow.Profile.isLoggedIn()&&this._isProactiveChat)
{var eo=new RightNow.Event.EventObject(this,{data:{"form":this._parentForm,"error_location":this._errorMessageDiv.get("id"),"f_tok":this.data.js.f_tok}});this.fire("collect",eo);}},_getReferrerUrl:function()
{var referrerUrl;var chatData=RightNow.Text.Encoding.base64Decode(RightNow.Url.getParameter("chat_data"));var dataValues=chatData.split('&');for(var index=0;index<dataValues.length;index++)
{var value=dataValues[index].split('=');if(value[0]==="referrerUrl")
{referrerUrl=decodeURIComponent(value[1]);break;}}
if(!referrerUrl)
{referrerUrl=document.referrer;if(!referrerUrl&&window.opener&&window.opener.location)
referrerUrl=window.opener.location.href;}
return referrerUrl;},_openChatWindow:function(){var parentForm=this.Y.one("#"+this._parentForm);if(!this._isProactiveChat)
{var leftPos=(screen.width/2)-(this.data.attrs.launch_width/2);var topPos=(screen.height/2)-(this.data.attrs.launch_height/2);var url='/euf/core/static/blank.html';if(this.Y.UA.ie===6)
url='';var chatWindowName=this.data.js.chatWindowName||'chatWindow';try
{if(this.data.attrs.open_in_new_window)
{if(!(this.Y.UA.chrome&&this.Y.UA.ios)){this.chatWindow=window.open(url,chatWindowName,'status=1,toolbar=0,menubar=0,location=0,resizable=1'+(this.data.attrs.enable_scrollbars?',scrollbars=1':'')+',height='+this.data.attrs.launch_height+'px,width='+this.data.attrs.launch_width+'px,left='+leftPos+',top='+topPos);this.chatWindow.focus();parentForm.set('target',chatWindowName);}
else
{parentForm.set('target','_blank');}}}
catch(e)
{this._toggleLoadingIndicators(false);return;}}
else
{try
{resizeTo(this.data.attrs.launch_height,this.data.attrs.launch_height+47);}
catch(e){}}
try
{this.fire("send",this.getValidatedFields());}
catch(e){}},_onFormValidated:function()
{if(this.data.attrs.is_persistent_chat)
{RightNow.Event.fire("evt_startPersistentChatRequest",new RightNow.Event.EventObject(this,{}));var UI=RightNow.Chat.UI;UI.EventBus=new UI.EventBus();UI.EventBus.initializeEventBus();}
else
{this._openChatWindow();}
if(RightNow.Profile.isLoggedIn())
{RightNow.Ajax.makeRequest("/ci/ajaxRequest/validateChatForm",{formToken:this.data.js.f_tok},{successHandler:this._onLoggedInVerification,scope:this,json:true});}
else
{this._onLoggedInVerification({status:true});}},_showErrorMessage:function(errorMessage)
{var error_span;if(this._errorLocation)
{error_span=document.getElementById(this._errorLocation);}
else
{if(this.data.attrs.is_persistent_chat)
{error_span=document.getElementById("rn_PCErrorLocation");}
else
{error_span=document.getElementById("rn_ErrorLocation");}}
error_span.style.display='block';var error_message=document.createElement("span");error_span.className="rn_MessageBox rn_ErrorMessage";error_message.className="ErrorSpan";error_message.innerHTML=errorMessage;error_span.appendChild(error_message);},_onLoggedInVerification:function(serverResponse)
{if(serverResponse.status===false)
{this._showErrorMessage(serverResponse.error);this.chatWindow.close();this._eventCanceled=true;return;}
this._toggleLoadingIndicators(false);},_addHiddenPostField:function(name,value)
{if(name!==undefined&&value!==undefined)
{var parentForm=this.Y.one("#"+this._parentForm);var input=this.Y.Node.create('<input name="'+name+'" type="" value="'+this.Y.Escape.html(value)+'">');parentForm.appendChild(input);RightNow.Form.find(this._parentForm,this.instanceID).on("submit",function(){var eventObject=new RightNow.Event.EventObject(this,{data:{name:name,value:value,required:false,form:this._parentForm}});RightNow.Event.fire("evt_formFieldValidatePass",eventObject);return eventObject;},this);}}}});
RightNow.namespace('Custom.Widgets.input.CustomSelectionInput');Custom.Widgets.input.CustomSelectionInput=RightNow.Widgets.SelectionInput.extend({overrides:{constructor:function(){var nodes=this.Y.one('#CustomFieldsOther');nodes.set("style","");nodes.get('children').addClass('rn_Hidden');this.parent();this.Y.on("change",this.methodName,document.getElementsByName('Incident.CustomFields.c.issue_list'),this,true);}},methodName:function(e){e.preventDefault();var nd=this.Y.one(this._inputSelector);var index=nd.get('selectedIndex');var vl=nd.get('value');var vlTxt=nd.get("options").item(index).get('text');var subFlag=true;var subTextParent=this.Y.one("#subjectField");try{var subText=subTextParent.all('input');subText.set("value",vlTxt);}catch(e){subFlag=false;}
var nodes=this.Y.one('#CustomFieldsOther');if(vl==16){nodes.get('children').replaceClass('','');var textBox=nodes.all('input');var otherText=textBox.getAttribute('name');textBox.set('required','true');if(subFlag){this.Y.on("blur",this.setSubjectFromOther,document.getElementsByName(otherText),this,true);}}else{nodes.get('children').addClass('rn_Hidden');var textBox=nodes.all('input');}},setSubjectFromOther:function(){var nodes=this.Y.one('#CustomFieldsOther');var textBox=nodes.all('input');var vl=textBox.get('value');var subTextParent=this.Y.one("#subjectField");var subText=subTextParent.all('input');subText.set("value",vl);},renderLabel:function(){var content=new EJS({text:this.getStatic().templates.label}).render({});},renderLegend:function(){var content=new EJS({text:this.getStatic().templates.legend}).render({});}});
