/* 
   This is a Utility class to hold all classes that could be shared between all other classes as needed.
   Add to this Utility class any class that could be shared by other classes across our SFDC Org.
      Date of Initial Creation: 02/14/2013
 */

/*
   Convert language to standard language code
      Date of Initial creation: 02/14/2013
*/
public class CommonUtils
{

   public static String getLangCode(String lang){
      string langcode;   
      if (lang == 'English' ) { langcode ='en_US';} else
      if (lang == 'Français' ) { langcode ='fr';} else
      if (lang == 'Deutsch' ) { langcode ='de';} else
      if (lang == 'Español' ) { langcode ='es';} else
      if (lang == 'Português' ) { langcode ='pt';} else
      langcode = lang;
      return langcode;
   }

/*
   Convert locale to standard locale code
      Date of Initial creation: 02/14/2013
*/
   public static String getLocCode(String loc){
      string loccode;
      if  (loc == 'Deutsch') {loccode = 'de'; } else
      if  (loc == 'Deutsch-Österreich') {loccode = 'de_AT'; } else
      if  (loc == 'Deutsch-Schweiz') {loccode = 'de_CH'; } else
      if  (loc == 'Deutsch-Deutschland') {loccode = 'de_DE'; } else
      if  (loc == 'Deutsch-Luxemburg') {loccode = 'de_LU'; } else
      if  (loc == 'English-Australia') {loccode = 'en_AU'; } else
      if  (loc == 'English-Canada') {loccode = 'en_CA'; } else
      if  (loc == 'English-United Kingdom') {loccode = 'en_GB'; } else
      if  (loc == 'English-Ireland') {loccode = 'en_IE'; } else
      if  (loc == 'English-India') {loccode = 'en_IN'; } else
      if  (loc == 'English-New Zealand') {loccode = 'en_NZ'; } else
      if  (loc == 'English-Philippines') {loccode = 'en_PH'; } else
      if  (loc == 'English-Pakistan') {loccode = 'en_PK'; } else
      if  (loc == 'English-Singapore') {loccode = 'en_SG'; } else
      if  (loc == 'English-United States') {loccode = 'en_US'; } else
      if  (loc == 'English-South Africa') {loccode = 'en_ZA'; } else
      if  (loc == 'Français') {loccode = 'fr'; } else
      if  (loc == 'Français-Belgique') {loccode = 'fr_BE'; } else
      if  (loc == 'Français-Canada') {loccode = 'fr_CA'; } else
      if  (loc == 'Français-Suisse') {loccode = 'fr_CH'; } else
      if  (loc == 'Français-France') {loccode = 'fr_FR'; } else
      if  (loc == 'Français-Luxembourg') {loccode = 'fr_LU'; } else
      if  (loc == 'español') {loccode = 'es'; } else
      if  (loc == 'español (Argentina)') {loccode = 'es_AR'; } else
      if  (loc == 'español (Bolivia)') {loccode = 'es_BO'; } else
      if  (loc == 'español (Chile)') {loccode = 'es_CL'; } else
      if  (loc == 'español (Colombia)') {loccode = 'es_CO'; } else
      if  (loc == 'español (Costa Rica)') {loccode = 'es_CR'; } else
      if  (loc == 'español (República Dominicana)') {loccode = 'es_DO'; } else
      if  (loc == 'español (Ecuador)') {loccode = 'es_EC'; } else
      if  (loc == 'español (España)') {loccode = 'es_ES'; } else
      if  (loc == 'español (Guatemala)') {loccode = 'es_GT'; } else
      if  (loc == 'español (Honduras)') {loccode = 'es_HN'; } else
      if  (loc == 'español (México)') {loccode = 'es_MX'; } else
      if  (loc == 'español (Nicaragua)') {loccode = 'es_NI'; } else
      if  (loc == 'español (Panamá)') {loccode = 'es_PA'; } else
      if  (loc == 'español (Perú)') {loccode = 'es_PE'; } else
      if  (loc == 'español (Puerto Rico)') {loccode = 'es_PR'; } else
      if  (loc == 'español (Paraguay)') {loccode = 'es_PY'; } else
      if  (loc == 'español (El Salvador)') {loccode = 'es_SV'; } else
      if  (loc == 'español (Estados Unidos)') {loccode = 'es_US'; } else
      if  (loc == 'español (Uruguay)') {loccode = 'es_UY'; } else
      if  (loc == 'español (Venezuela)') {loccode = 'es_VE'; } else
      if  (loc == 'português') {loccode = 'pt'; } else
      if  (loc == 'português (Brasil)') {loccode = 'pt_BR'; } else
      if  (loc == 'português (Portugal)') {loccode = 'pt_PT'; } else
      loccode = loc;
      return loccode;
   }

/*
   Convert timezone to standard timezone code
      Date of Initial creation: 02/14/2013
*/
   public static String getTzoneCode(String tzone){
      string tzonecode;
      if  (tzone == 'Line Islands Time (Pacific/Kiritimati)') {tzonecode = 'Pacific/Kiritimati'; } else
      if  (tzone == 'Chatham Time (Pacific/Chatham)') {tzonecode = 'Pacific/Chatham'; } else
      if  (tzone == 'New Zealand Time (Pacific/Auckland)') {tzonecode = 'Pacific/Auckland'; } else
      if  (tzone == 'Phoenix Islands Time (Pacific/Enderbury)') {tzonecode = 'Pacific/Enderbury'; } else
      if  (tzone == 'Tonga Time (Pacific/Tongatapu)') {tzonecode = 'Pacific/Tongatapu'; } else
      if  (tzone == 'Magadan Time (Asia/Kamchatka)') {tzonecode = 'Asia/Kamchatka'; } else
      if  (tzone == 'Fiji Time (Pacific/Fiji)') {tzonecode = 'Pacific/Fiji'; } else
      if  (tzone == 'Norfolk Islands Time (Pacific/Norfolk)') {tzonecode = 'Pacific/Norfolk'; } else
      if  (tzone == 'Lord Howe Time (Australia/Lord_Howe)') {tzonecode = 'Australia/Lord_Howe'; } else
      if  (tzone == 'Australian Eastern Time (Australia/Sydney)') {tzonecode = 'Australia/Sydney'; } else
      if  (tzone == 'Solomon Islands Time (Pacific/Guadalcanal)') {tzonecode = 'Pacific/Guadalcanal'; } else
      if  (tzone == 'Australian Central Time (Australia/Adelaide)') {tzonecode = 'Australia/Adelaide'; } else
      if  (tzone == 'Australian Eastern Standard Time (Australia/Brisbane)') {tzonecode = 'Australia/Brisbane'; } else
      if  (tzone == 'Australian Central Standard Time (Australia/Darwin)') {tzonecode = 'Australia/Darwin'; } else
      if  (tzone == 'Korean Standard Time (Asia/Seoul)') {tzonecode = 'Asia/Seoul'; } else
      if  (tzone == 'Japan Standard Time (Asia/Tokyo)') {tzonecode = 'Asia/Tokyo'; } else
      if  (tzone == 'Hong Kong Time (Asia/Hong_Kong)') {tzonecode = 'Asia/Hong_Kong'; } else
      if  (tzone == 'Malaysia Time (Asia/Kuala_Lumpur)') {tzonecode = 'Asia/Kuala_Lumpur'; } else
      if  (tzone == 'Philippine Time (Asia/Manila)') {tzonecode = 'Asia/Manila'; } else
      if  (tzone == 'China Standard Time (Asia/Shanghai)') {tzonecode = 'Asia/Shanghai'; } else
      if  (tzone == 'Singapore Standard Time (Asia/Singapore)') {tzonecode = 'Asia/Singapore'; } else
      if  (tzone == 'Taipei Standard Time (Asia/Taipei)') {tzonecode = 'Asia/Taipei'; } else
      if  (tzone == 'Australian Western Standard Time (Australia/Perth)') {tzonecode = 'Australia/Perth'; } else
      if  (tzone == 'Indochina Time (Asia/Bangkok)') {tzonecode = 'Asia/Bangkok'; } else
      if  (tzone == 'Western Indonesia Time (Asia/Jakarta)') {tzonecode = 'Asia/Jakarta'; } else
      if  (tzone == 'Indochina Time (Asia/Saigon)') {tzonecode = 'Asia/Saigon'; } else
      if  (tzone == 'Myanmar Time (Asia/Rangoon)') {tzonecode = 'Asia/Rangoon'; } else
      if  (tzone == 'Bangladesh Time (Asia/Dacca)') {tzonecode = 'Asia/Dacca'; } else
      if  (tzone == 'Yekaterinburg Time (Asia/Yekaterinburg)') {tzonecode = 'Asia/Yekaterinburg'; } else
      if  (tzone == 'Nepal Time (Asia/Katmandu)') {tzonecode = 'Asia/Katmandu'; } else
      if  (tzone == 'India Standard Time (Asia/Calcutta)') {tzonecode = 'Asia/Calcutta'; } else
      if  (tzone == 'India Standard Time (Asia/Colombo)') {tzonecode = 'Asia/Colombo'; } else
      if  (tzone == 'Pakistan Time (Asia/Karachi)') {tzonecode = 'Asia/Karachi'; } else
      if  (tzone == 'Uzbekistan Time (Asia/Tashkent)') {tzonecode = 'Asia/Tashkent'; } else
      if  (tzone == 'Afghanistan Time (Asia/Kabul)') {tzonecode = 'Asia/Kabul'; } else
      if  (tzone == 'Gulf Standard Time (Asia/Dubai)') {tzonecode = 'Asia/Dubai'; } else
      if  (tzone == 'Georgia Time (Asia/Tbilisi)') {tzonecode = 'Asia/Tbilisi'; } else
      if  (tzone == 'Moscow Standard Time (Europe/Moscow)') {tzonecode = 'Europe/Moscow'; } else
      if  (tzone == 'Iran Time (Asia/Tehran)') {tzonecode = 'Asia/Tehran'; } else
      if  (tzone == 'East Africa Time (Africa/Nairobi)') {tzonecode = 'Africa/Nairobi'; } else
      if  (tzone == 'Arabian Standard Time (Asia/Baghdad)') {tzonecode = 'Asia/Baghdad'; } else
      if  (tzone == 'Arabian Standard Time (Asia/Kuwait)') {tzonecode = 'Asia/Kuwait'; } else
      if  (tzone == 'Arabian Standard Time (Asia/Riyadh)') {tzonecode = 'Asia/Riyadh'; } else
      if  (tzone == 'Eastern European Time (Europe/Athens)') {tzonecode = 'Europe/Athens'; } else
      if  (tzone == 'Eastern European Time (Europe/Bucharest)') {tzonecode = 'Europe/Bucharest'; } else
      if  (tzone == 'Eastern European Time (Europe/Helsinki)') {tzonecode = 'Europe/Helsinki'; } else
      if  (tzone == 'Eastern European Time (Europe/Istanbul)') {tzonecode = 'Europe/Istanbul'; } else
      if  (tzone == 'Eastern European Time (Europe/Minsk)') {tzonecode = 'Europe/Minsk'; } else
      if  (tzone == 'Eastern European Time (Africa/Cairo)') {tzonecode = 'Africa/Cairo'; } else
      if  (tzone == 'South Africa Standard Time (Africa/Johannesburg)') {tzonecode = 'Africa/Johannesburg'; } else
      if  (tzone == 'Israel Time (Asia/Jerusalem)') {tzonecode = 'Asia/Jerusalem'; } else
      if  (tzone == 'Central European Time (Europe/Amsterdam)') {tzonecode = 'Europe/Amsterdam'; } else
      if  (tzone == 'Central European Time (Europe/Berlin)') {tzonecode = 'Europe/Berlin'; } else
      if  (tzone == 'Central European Time (Europe/Brussels)') {tzonecode = 'Europe/Brussels'; } else
      if  (tzone == 'Central European Time (Europe/Paris)') {tzonecode = 'Europe/Paris'; } else
      if  (tzone == 'Central European Time (Europe/Prague)') {tzonecode = 'Europe/Prague'; } else
      if  (tzone == 'Central European Time (Europe/Rome)') {tzonecode = 'Europe/Rome'; } else
      if  (tzone == 'Central European Time (Africa/Algiers)') {tzonecode = 'Africa/Algiers'; } else
      if  (tzone == 'Irish Time (Europe/Dublin)') {tzonecode = 'Europe/Dublin'; } else
      if  (tzone == 'Western European Time (Europe/Lisbon)') {tzonecode = 'Europe/Lisbon'; } else
      if  (tzone == 'British Time (Europe/London)') {tzonecode = 'Europe/London'; } else
      if  (tzone == 'Greenwich Mean Time (GMT)') {tzonecode = 'GMT'; } else
      if  (tzone == 'Cape Verde Time (Atlantic/Cape_Verde)') {tzonecode = 'Atlantic/Cape_Verde'; } else
      if  (tzone == 'South Georgia Time (Atlantic/South_Georgia)') {tzonecode = 'Atlantic/South_Georgia'; } else
      if  (tzone == 'Newfoundland Time (America/St_Johns)') {tzonecode = 'America/St_Johns'; } else
      if  (tzone == 'Argentina Time (America/Buenos_Aires)') {tzonecode = 'America/Buenos_Aires'; } else
      if  (tzone == 'Atlantic Time (America/Halifax)') {tzonecode = 'America/Halifax'; } else
      if  (tzone == 'Chile Time (America/Santiago)') {tzonecode = 'America/Santiago'; } else
      if  (tzone == 'Brasilia Time (America/Sao_Paulo)') {tzonecode = 'America/Sao_Paulo'; } else
      if  (tzone == 'Atlantic Time (Atlantic/Bermuda)') {tzonecode = 'Atlantic/Bermuda'; } else
      if  (tzone == 'Eastern Time (America/Indianapolis)') {tzonecode = 'America/Indianapolis'; } else
      if  (tzone == 'Eastern Time (America/New_York)') {tzonecode = 'America/New_York'; } else
      if  (tzone == 'Atlantic Standard Time (America/Puerto_Rico)') {tzonecode = 'America/Puerto_Rico'; } else
      if  (tzone == 'Venezuela Time (America/Caracas)') {tzonecode = 'America/Caracas'; } else
      if  (tzone == 'Colombia Time (America/Bogota)') {tzonecode = 'America/Bogota'; } else
      if  (tzone == 'Central Time (America/Chicago)') {tzonecode = 'America/Chicago'; } else
      if  (tzone == 'Peru Time (America/Lima)') {tzonecode = 'America/Lima'; } else
      if  (tzone == 'Central Time (America/Mexico_City)') {tzonecode = 'America/Mexico_City'; } else
      if  (tzone == 'Eastern Standard Time (America/Panama)') {tzonecode = 'America/Panama'; } else
      if  (tzone == 'Mountain Time (America/Denver)') {tzonecode = 'America/Denver'; } else
      if  (tzone == 'Central Standard Time (America/El_Salvador)') {tzonecode = 'America/El_Salvador'; } else
      if  (tzone == 'Pacific Time (America/Los_Angeles)') {tzonecode = 'America/Los_Angeles'; } else
      if  (tzone == 'Mountain Standard Time (America/Phoenix)') {tzonecode = 'America/Phoenix'; } else
      if  (tzone == 'Pacific Time (America/Tijuana)') {tzonecode = 'America/Tijuana'; } else
      if  (tzone == 'Alaska Time (America/Anchorage)') {tzonecode = 'America/Anchorage'; } else
      if  (tzone == 'Hawaii-Aleutian Standard Time (Pacific/Honolulu)') {tzonecode = 'Pacific/Honolulu'; } else
      if  (tzone == 'Niue Time (Pacific/Niue)') {tzonecode = 'Pacific/Niue'; } else
      if  (tzone == 'Samoa Standard Time (Pacific/Pago_Pago)') {tzonecode = 'Pacific/Pago_Pago'; } else
      tzonecode = tzone;
      return tzonecode;
   }


}