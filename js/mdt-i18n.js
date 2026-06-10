/*
 * NTOG MDT forms — shared i18n engine + dictionary.
 *
 * Languages: en (source), fi, sv, no (Norwegian Bokmål), da, is (Icelandic).
 * Keyed by short stable ids. Missing strings fall back to English.
 *
 * NOTE: Clinical terminology in fi/sv/no/da/is is provided for review.
 * Native-speaker clinical verification is recommended before formal use.
 *
 * Usage:
 *   <script src="/js/mdt-i18n.js"></script>
 *   MDTI18N.init(document.getElementById('langSelect'));
 *   // mark text:        <h2 data-i18n="sec.meeting">Meeting</h2>
 *   // mark placeholder: <textarea data-i18n-ph="ph.comorbidities"></textarea>
 *   // in JS:            MDTI18N.t('sum.title')
 *   // re-render on change: window.addEventListener('mdt:langchange', render)
 */
(function (global) {
  "use strict";

  var LANGS = ["en", "fi", "sv", "no", "da", "is"];
  var LANG_NAMES = { en: "English", fi: "Suomi", sv: "Svenska", no: "Norsk", da: "Dansk", is: "Íslenska" };

  // Dictionary: id -> { en, fi, sv, no, da, is }
  var S = {
    // ---- chrome ----
    "app.langLabel": { en: "Language", fi: "Kieli", sv: "Språk", no: "Språk", da: "Sprog", is: "Tungumál" },
    "app.title.mini": { en: "Lung cancer MDT — structured (mini)", fi: "Keuhkosyövän MDT — strukturoitu (mini)", sv: "Lungcancer-MDK — strukturerad (mini)", no: "Lungekreft-MDT — strukturert (mini)", da: "Lungekræft-MDT — struktureret (mini)", is: "Lungnakrabbamein MDT — skipulagt (mini)" },
    "app.title.open": { en: "Lung cancer MDT — open form", fi: "Keuhkosyövän MDT — avoin lomake", sv: "Lungcancer-MDK — öppet formulär", no: "Lungekreft-MDT — åpent skjema", da: "Lungekræft-MDT — åbent skema", is: "Lungnakrabbamein MDT — opið eyðublað" },
    "app.intro.mini": { en: "A compact, structured browser tool for lung cancer MDT preparation. Same items as the open form, with coded fields. Research and education use only.", fi: "Tiivis, strukturoitu selainpohjainen työkalu keuhkosyövän MDT-valmisteluun. Samat kohdat kuin avoimessa lomakkeessa, koodatuilla kentillä. Vain tutkimus- ja opetuskäyttöön.", sv: "Ett kompakt, strukturerat webbverktyg för förberedelse inför lungcancer-MDK. Samma punkter som det öppna formuläret, med kodade fält. Endast för forsknings- och utbildningsbruk.", no: "Et kompakt, strukturert nettverktøy for forberedelse til lungekreft-MDT. Samme punkter som det åpne skjemaet, med kodede felt. Kun til forsknings- og undervisningsbruk.", da: "Et kompakt, struktureret browserværktøj til forberedelse af lungekræft-MDT. Samme punkter som det åbne skema, med kodede felter. Kun til forsknings- og undervisningsbrug.", is: "Þétt, skipulagt vafratól til undirbúnings lungnakrabbameins-MDT. Sömu atriði og opna eyðublaðið, með kóðuðum reitum. Eingöngu til rannsókna og kennslu." },
    "app.intro.open": { en: "A browser tool for lung cancer MDT preparation using free-text fields. Research and education use only.", fi: "Selainpohjainen työkalu keuhkosyövän MDT-valmisteluun vapaatekstikentillä. Vain tutkimus- ja opetuskäyttöön.", sv: "Ett webbverktyg för förberedelse inför lungcancer-MDK med fritextfält. Endast för forsknings- och utbildningsbruk.", no: "Et nettverktøy for forberedelse til lungekreft-MDT med fritekstfelt. Kun til forsknings- og undervisningsbruk.", da: "Et browserværktøj til forberedelse af lungekræft-MDT med fritekstfelter. Kun til forsknings- og undervisningsbrug.", is: "Vafratól til undirbúnings lungnakrabbameins-MDT með frítextareitum. Eingöngu til rannsókna og kennslu." },
    "app.privacy": { en: "Privacy: This form runs entirely in your browser. No data is sent anywhere. Refreshing the page clears all fields. Do not share content containing identifiable patient information outside approved clinical systems.", fi: "Tietosuoja: Lomake toimii kokonaan selaimessasi. Tietoja ei lähetetä mihinkään. Sivun päivitys tyhjentää kaikki kentät. Älä jaa tunnistettavaa potilastietoa sisältävää sisältöä hyväksyttyjen kliinisten järjestelmien ulkopuolelle.", sv: "Integritet: Formuläret körs helt i din webbläsare. Inga data skickas någonstans. Om sidan laddas om rensas alla fält. Dela inte innehåll med identifierbara patientuppgifter utanför godkända kliniska system.", no: "Personvern: Skjemaet kjører helt i nettleseren din. Ingen data sendes noe sted. Oppdatering av siden tømmer alle felt. Ikke del innhold med identifiserbare pasientopplysninger utenfor godkjente kliniske systemer.", da: "Privatliv: Skemaet kører udelukkende i din browser. Ingen data sendes nogen steder. Genindlæsning af siden rydder alle felter. Del ikke indhold med identificerbare patientoplysninger uden for godkendte kliniske systemer.", is: "Persónuvernd: Eyðublaðið keyrir alfarið í vafranum þínum. Engin gögn eru send neitt. Endurhleðsla síðunnar hreinsar alla reiti. Ekki deila efni með persónugreinanlegum sjúklingaupplýsingum utan samþykktra klínískra kerfa." },
    "app.disclaimer": { en: "Use: This is a structured preparation and teaching tool for MDT discussion. It does not replace national guidelines, local protocols, clinical judgment, or formal MDT documentation systems.", fi: "Käyttö: Tämä on strukturoitu valmistelu- ja opetustyökalu MDT-keskustelua varten. Se ei korvaa kansallisia hoitosuosituksia, paikallisia ohjeita, kliinistä harkintaa tai virallisia MDT-dokumentointijärjestelmiä.", sv: "Användning: Detta är ett strukturerat förberedelse- och utbildningsverktyg för MDK-diskussion. Det ersätter inte nationella riktlinjer, lokala protokoll, klinisk bedömning eller formella MDK-dokumentationssystem.", no: "Bruk: Dette er et strukturert forberedelses- og undervisningsverktøy for MDT-diskusjon. Det erstatter ikke nasjonale retningslinjer, lokale protokoller, klinisk skjønn eller formelle MDT-dokumentasjonssystemer.", da: "Brug: Dette er et struktureret forberedelses- og undervisningsværktøj til MDT-diskussion. Det erstatter ikke nationale retningslinjer, lokale protokoller, klinisk dømmekraft eller formelle MDT-dokumentationssystemer.", is: "Notkun: Þetta er skipulagt undirbúnings- og kennslutól fyrir MDT-umræðu. Það kemur ekki í stað landsleiðbeininga, staðbundinna verkferla, klínísks mats eða formlegra MDT-skráningarkerfa." },

    // ---- sections ----
    "sec.meeting": { en: "Meeting", fi: "Kokous", sv: "Möte", no: "Møte", da: "Møde", is: "Fundur" },
    "sec.patient": { en: "Patient", fi: "Potilas", sv: "Patient", no: "Pasient", da: "Patient", is: "Sjúklingur" },
    "sec.comorbidity": { en: "Comorbidity and medication", fi: "Liitännäissairaudet ja lääkitys", sv: "Samsjuklighet och medicinering", no: "Komorbiditet og medisinering", da: "Komorbiditet og medicinering", is: "Fylgisjúkdómar og lyfjameðferð" },
    "sec.functional": { en: "Functional status", fi: "Toimintakyky", sv: "Funktionsstatus", no: "Funksjonsstatus", da: "Funktionsstatus", is: "Færnistaða" },
    "sec.lungfn": { en: "Lung function", fi: "Keuhkojen toiminta", sv: "Lungfunktion", no: "Lungefunksjon", da: "Lungefunktion", is: "Lungnastarfsemi" },
    "sec.imaging": { en: "Imaging", fi: "Kuvantaminen", sv: "Bilddiagnostik", no: "Bildediagnostikk", da: "Billeddiagnostik", is: "Myndgreining" },
    "sec.pathology": { en: "Pathology", fi: "Patologia", sv: "Patologi", no: "Patologi", da: "Patologi", is: "Meinafræði" },
    "sec.biomarkers": { en: "Biomarkers", fi: "Biomarkkerit", sv: "Biomarkörer", no: "Biomarkører", da: "Biomarkører", is: "Lífvísar" },
    "sec.preference": { en: "Patient preference", fi: "Potilaan toive", sv: "Patientens önskemål", no: "Pasientens preferanse", da: "Patientens præference", is: "Óskir sjúklings" },
    "sec.recommendation": { en: "MDT recommendation", fi: "MDT-suositus", sv: "MDK-rekommendation", no: "MDT-anbefaling", da: "MDT-anbefaling", is: "MDT-tillaga" },

    // ---- imaging submodule legends ----
    "img.overview": { en: "Imaging overview", fi: "Kuvantamisen yhteenveto", sv: "Översikt bilddiagnostik", no: "Oversikt bildediagnostikk", da: "Oversigt billeddiagnostik", is: "Yfirlit myndgreiningar" },
    "img.baselineCT": { en: "Baseline diagnostic CT", fi: "Diagnostinen perus-TT", sv: "Diagnostisk bas-DT", no: "Diagnostisk basis-CT", da: "Diagnostisk basis-CT", is: "Grunnlínu greiningar-TS" },
    "img.pet": { en: "PET-CT", fi: "PET-TT", sv: "PET-DT", no: "PET-CT", da: "PET-CT", is: "PET-TS" },
    "img.brain": { en: "Brain imaging", fi: "Aivojen kuvantaminen", sv: "Hjärnavbildning", no: "Hjernebildediagnostikk", da: "Hjernescanning", is: "Heilamyndgreining" },
    "img.previous": { en: "Previous and comparison imaging", fi: "Aiemmat ja vertailukuvat", sv: "Tidigare och jämförande bilder", no: "Tidligere og sammenlignende bilder", da: "Tidligere og sammenlignende billeder", is: "Fyrri og samanburðarmyndir" },
    "img.radreview": { en: "Radiology review for MDT", fi: "Radiologian arvio MDT:tä varten", sv: "Radiologigranskning inför MDK", no: "Radiologivurdering for MDT", da: "Radiologigennemgang til MDT", is: "Myndgreiningaryfirferð fyrir MDT" },

    // ---- field labels ----
    "f.meetingDate": { en: "Meeting date", fi: "Kokouksen päivämäärä", sv: "Mötesdatum", no: "Møtedato", da: "Mødedato", is: "Fundardagur" },
    "f.presenter": { en: "Presenter", fi: "Esittelijä", sv: "Föredragande", no: "Presentatør", da: "Fremlægger", is: "Kynnir" },
    "f.hospital": { en: "Hospital / centre", fi: "Sairaala / keskus", sv: "Sjukhus / centrum", no: "Sykehus / senter", da: "Hospital / center", is: "Sjúkrahús / miðstöð" },
    "f.age": { en: "Age", fi: "Ikä", sv: "Ålder", no: "Alder", da: "Alder", is: "Aldur" },
    "f.sex": { en: "Sex", fi: "Sukupuoli", sv: "Kön", no: "Kjønn", da: "Køn", is: "Kyn" },
    "f.smokingStatus": { en: "Smoking status", fi: "Tupakointistatus", sv: "Rökstatus", no: "Røykestatus", da: "Rygestatus", is: "Reykingastaða" },
    "f.packYears": { en: "Pack-years", fi: "Askivuodet", sv: "Paketår", no: "Pakkeår", da: "Pakkeår", is: "Pakkaár" },
    "f.quitYears": { en: "Years since quitting", fi: "Vuosia lopettamisesta", sv: "År sedan rökstopp", no: "År siden røykeslutt", da: "År siden rygestop", is: "Ár frá því hætt var" },
    "f.weight": { en: "Weight (kg)", fi: "Paino (kg)", sv: "Vikt (kg)", no: "Vekt (kg)", da: "Vægt (kg)", is: "Þyngd (kg)" },
    "f.height": { en: "Height (cm)", fi: "Pituus (cm)", sv: "Längd (cm)", no: "Høyde (cm)", da: "Højde (cm)", is: "Hæð (cm)" },
    "f.bmi": { en: "BMI", fi: "BMI", sv: "BMI", no: "BMI", da: "BMI", is: "BMI" },
    "f.comorbidities": { en: "Significant comorbidities", fi: "Merkittävät liitännäissairaudet", sv: "Betydande samsjuklighet", no: "Betydelig komorbiditet", da: "Betydelig komorbiditet", is: "Marktækir fylgisjúkdómar" },
    "f.prevCancer": { en: "Previous cancers and surgeries", fi: "Aiemmat syövät ja leikkaukset", sv: "Tidigare cancer och operationer", no: "Tidligere kreft og operasjoner", da: "Tidligere kræft og operationer", is: "Fyrri krabbamein og aðgerðir" },
    "f.anticoag": { en: "Anticoagulation and immunosuppression", fi: "Antikoagulaatio ja immunosuppressio", sv: "Antikoagulation och immunsuppression", no: "Antikoagulasjon og immunsuppresjon", da: "Antikoagulation og immunsuppression", is: "Blóðþynning og ónæmisbæling" },
    "f.ecog": { en: "WHO / ECOG performance status", fi: "WHO / ECOG -toimintakyky", sv: "WHO / ECOG funktionsstatus", no: "WHO / ECOG funksjonsstatus", da: "WHO / ECOG funktionsstatus", is: "WHO / ECOG færnistaða" },
    "f.g8": { en: "G8 score", fi: "G8-pisteet", sv: "G8-poäng", no: "G8-skår", da: "G8-score", is: "G8-stig" },
    "f.performance": { en: "Performance / exercise capacity", fi: "Suorituskyky / rasituksensieto", sv: "Prestations- / arbetskapacitet", no: "Yteevne / treningskapasitet", da: "Præstations- / arbejdskapacitet", is: "Afkastageta / áreynsluþol" },
    "f.fvc": { en: "FVC", fi: "FVC", sv: "FVC", no: "FVC", da: "FVC", is: "FVC" },
    "f.fev1": { en: "FEV1", fi: "FEV1", sv: "FEV1", no: "FEV1", da: "FEV1", is: "FEV1" },
    "f.dlco": { en: "DLCO", fi: "DLCO", sv: "DLCO", no: "DLCO", da: "DLCO", is: "DLCO" },
    "f.dlcoVa": { en: "DLCO/VA (%)", fi: "DLCO/VA (%)", sv: "DLCO/VA (%)", no: "DLCO/VA (%)", da: "DLCO/VA (%)", is: "DLCO/VA (%)" },
    "f.vq": { en: "V/Q scan result", fi: "V/Q-kuvauksen tulos", sv: "V/Q-skintigrafiresultat", no: "V/Q-skanresultat", da: "V/Q-skanresultat", is: "V/Q-skönnunarniðurstaða" },
    "f.ctDate": { en: "CT date", fi: "TT-päivämäärä", sv: "DT-datum", no: "CT-dato", da: "CT-dato", is: "TS-dagur" },
    "f.ctRegion": { en: "CT region", fi: "TT-alue", sv: "DT-region", no: "CT-region", da: "CT-region", is: "TS-svæði" },
    "f.ctContrast": { en: "Contrast", fi: "Varjoaine", sv: "Kontrast", no: "Kontrast", da: "Kontrast", is: "Skuggaefni" },
    "f.ctFindings": { en: "Primary lesion and thoracic findings", fi: "Primaarileesio ja thorax-löydökset", sv: "Primärlesion och torakala fynd", no: "Primærlesjon og torakale funn", da: "Primær læsion og torakale fund", is: "Frummein og brjóstholsfundir" },
    "f.ctNodes": { en: "Nodal findings on CT", fi: "Imusolmukelöydökset TT:ssä", sv: "Lymfkörtelfynd på DT", no: "Lymfeknutefunn på CT", da: "Lymfeknudefund på CT", is: "Eitlafundir á TS" },
    "f.ctExtra": { en: "Extrathoracic / adrenal / liver / bone findings on CT", fi: "Ekstratorakaaliset / lisämunuais- / maksa- / luulöydökset TT:ssä", sv: "Extratorakala / binjure- / lever- / skelettfynd på DT", no: "Ekstratorakale / binyre- / lever- / skjelettfunn på CT", da: "Ekstratorakale / binyre- / lever- / knoglefund på CT", is: "Utan brjósthols / nýrnahettu- / lifrar- / beinfundir á TS" },
    "f.petDate": { en: "PET-CT date", fi: "PET-TT-päivämäärä", sv: "PET-DT-datum", no: "PET-CT-dato", da: "PET-CT-dato", is: "PET-TS-dagur" },
    "f.petStatus": { en: "PET status", fi: "PET-status", sv: "PET-status", no: "PET-status", da: "PET-status", is: "PET-staða" },
    "f.petCtComparison": { en: "Comparison with CT", fi: "Vertailu TT:hen", sv: "Jämförelse med DT", no: "Sammenligning med CT", da: "Sammenligning med CT", is: "Samanburður við TS" },
    "f.petFindings": { en: "PET-CT findings", fi: "PET-TT-löydökset", sv: "PET-DT-fynd", no: "PET-CT-funn", da: "PET-CT-fund", is: "PET-TS fundir" },
    "f.petConfirm": { en: "Sites needing confirmation", fi: "Varmistusta vaativat kohteet", sv: "Lokaler som behöver bekräftas", no: "Steder som trenger bekreftelse", da: "Lokalisationer der kræver bekræftelse", is: "Staðir sem þarf að staðfesta" },
    "f.brainDate": { en: "Brain imaging date", fi: "Aivokuvauksen päivämäärä", sv: "Datum hjärnavbildning", no: "Dato hjernebildediagnostikk", da: "Dato hjernescanning", is: "Dagur heilamyndgreiningar" },
    "f.brainModality": { en: "Brain imaging modality", fi: "Aivokuvauksen modaliteetti", sv: "Modalitet hjärnavbildning", no: "Modalitet hjernebildediagnostikk", da: "Modalitet hjernescanning", is: "Aðferð heilamyndgreiningar" },
    "f.brainContrast": { en: "Contrast", fi: "Varjoaine", sv: "Kontrast", no: "Kontrast", da: "Kontrast", is: "Skuggaefni" },
    "f.brainFindings": { en: "Brain imaging findings", fi: "Aivokuvauksen löydökset", sv: "Fynd hjärnavbildning", no: "Funn hjernebildediagnostikk", da: "Fund hjernescanning", is: "Fundir heilamyndgreiningar" },
    "f.prevCtDate": { en: "Previous CT date", fi: "Aiemman TT:n päivämäärä", sv: "Tidigare DT-datum", no: "Tidligere CT-dato", da: "Tidligere CT-dato", is: "Fyrri TS-dagur" },
    "f.prevPetDate": { en: "Previous PET-CT date", fi: "Aiemman PET-TT:n päivämäärä", sv: "Tidigare PET-DT-datum", no: "Tidligere PET-CT-dato", da: "Tidligere PET-CT-dato", is: "Fyrri PET-TS-dagur" },
    "f.otherImagingDate": { en: "Other comparison date", fi: "Muu vertailupäivämäärä", sv: "Annat jämförelsedatum", no: "Annen sammenligningsdato", da: "Anden sammenligningsdato", is: "Annar samanburðardagur" },
    "f.growth": { en: "Growth / stability / volume doubling time", fi: "Kasvu / stabiliteetti / tilavuuden kaksinkertaistumisaika", sv: "Tillväxt / stabilitet / volymfördubblingstid", no: "Vekst / stabilitet / volumdoblingstid", da: "Vækst / stabilitet / volumenfordoblingstid", is: "Vöxtur / stöðugleiki / rúmmáls-tvöföldunartími" },
    "f.priorImaging": { en: "Prior imaging relevance", fi: "Aiempien kuvien merkitys", sv: "Relevans av tidigare bilder", no: "Relevans av tidligere bilder", da: "Relevans af tidligere billeder", is: "Mikilvægi fyrri mynda" },
    "f.radiologyReviewDate": { en: "Radiology review date", fi: "Radiologian arviointipäivämäärä", sv: "Datum radiologigranskning", no: "Dato radiologivurdering", da: "Dato radiologigennemgang", is: "Dagur myndgreiningaryfirferðar" },
    "f.radiologistPresent": { en: "Radiologist present at MDT?", fi: "Radiologi läsnä MDT:ssä?", sv: "Radiolog närvarande vid MDK?", no: "Radiolog til stede ved MDT?", da: "Radiolog til stede ved MDT?", is: "Röntgenlæknir viðstaddur MDT?" },
    "f.imagingComplete": { en: "Imaging complete for staging?", fi: "Kuvantaminen riittävä levinneisyysmääritykseen?", sv: "Bilddiagnostik fullständig för stadieindelning?", no: "Bildediagnostikk komplett for stadieinndeling?", da: "Billeddiagnostik komplet til stadieinddeling?", is: "Myndgreining fullnægjandi fyrir stigun?" },
    "f.radiologyQuestion": { en: "Radiology MDT question", fi: "Radiologinen MDT-kysymys", sv: "Radiologisk MDK-fråga", no: "Radiologisk MDT-spørsmål", da: "Radiologisk MDT-spørgsmål", is: "Myndgreiningar MDT-spurning" },
    "f.radiologyConclusion": { en: "Radiology conclusion / missing imaging", fi: "Radiologian johtopäätös / puuttuva kuvantaminen", sv: "Radiologisk slutsats / saknad bilddiagnostik", no: "Radiologisk konklusjon / manglende bildediagnostikk", da: "Radiologisk konklusion / manglende billeddiagnostik", is: "Niðurstaða myndgreiningar / vantar myndir" },
    "f.otherImaging": { en: "Other imaging studies", fi: "Muut kuvantamistutkimukset", sv: "Andra bildundersökningar", no: "Andre bildeundersøkelser", da: "Andre billedundersøgelser", is: "Aðrar myndrannsóknir" },
    "f.diagSample": { en: "Diagnostic sample", fi: "Diagnostinen näyte", sv: "Diagnostiskt prov", no: "Diagnostisk prøve", da: "Diagnostisk prøve", is: "Greiningarsýni" },
    "f.histology": { en: "Histology / cytology", fi: "Histologia / sytologia", sv: "Histologi / cytologi", no: "Histologi / cytologi", da: "Histologi / cytologi", is: "Vefjafræði / frumufræði" },
    "f.diameter": { en: "Largest tumour diameter (cm)", fi: "Suurin kasvaimen halkaisija (cm)", sv: "Största tumördiameter (cm)", no: "Største tumordiameter (cm)", da: "Største tumordiameter (cm)", is: "Mesta æxlisþvermál (cm)" },
    "f.staging": { en: "Staging investigations and findings", fi: "Levinneisyystutkimukset ja löydökset", sv: "Stadieindelningsundersökningar och fynd", no: "Stadieinndelingsundersøkelser og funn", da: "Stadieinddelingsundersøgelser og fund", is: "Stigunarrannsóknir og fundir" },
    "f.cTNM1": { en: "c1-TNM before MDT", fi: "c1-TNM ennen MDT:tä", sv: "c1-TNM före MDK", no: "c1-TNM før MDT", da: "c1-TNM før MDT", is: "c1-TNM fyrir MDT" },
    "f.pdl1": { en: "PD-L1 (TPS, %)", fi: "PD-L1 (TPS, %)", sv: "PD-L1 (TPS, %)", no: "PD-L1 (TPS, %)", da: "PD-L1 (TPS, %)", is: "PD-L1 (TPS, %)" },
    "f.egfr": { en: "EGFR", fi: "EGFR", sv: "EGFR", no: "EGFR", da: "EGFR", is: "EGFR" },
    "f.alk": { en: "ALK fusion", fi: "ALK-fuusio", sv: "ALK-fusion", no: "ALK-fusjon", da: "ALK-fusion", is: "ALK-samruni" },
    "f.ros1": { en: "ROS1 fusion", fi: "ROS1-fuusio", sv: "ROS1-fusion", no: "ROS1-fusjon", da: "ROS1-fusion", is: "ROS1-samruni" },
    "f.braf": { en: "BRAF", fi: "BRAF", sv: "BRAF", no: "BRAF", da: "BRAF", is: "BRAF" },
    "f.kras": { en: "KRAS", fi: "KRAS", sv: "KRAS", no: "KRAS", da: "KRAS", is: "KRAS" },
    "f.met": { en: "MET", fi: "MET", sv: "MET", no: "MET", da: "MET", is: "MET" },
    "f.ret": { en: "RET fusions", fi: "RET-fuusiot", sv: "RET-fusioner", no: "RET-fusjoner", da: "RET-fusioner", is: "RET-samrunar" },
    "f.her2": { en: "ERBB2 / HER2", fi: "ERBB2 / HER2", sv: "ERBB2 / HER2", no: "ERBB2 / HER2", da: "ERBB2 / HER2", is: "ERBB2 / HER2" },
    "f.ntrk": { en: "NTRK1 to 3 fusions", fi: "NTRK1–3-fuusiot", sv: "NTRK1–3-fusioner", no: "NTRK1–3-fusjoner", da: "NTRK1–3-fusioner", is: "NTRK1–3-samrunar" },
    "f.otherNgs": { en: "Other NGS findings", fi: "Muut NGS-löydökset", sv: "Andra NGS-fynd", no: "Andre NGS-funn", da: "Andre NGS-fund", is: "Aðrir NGS-fundir" },
    "f.patientPref": { en: "Patient's treatment preference, concerns, and information needs", fi: "Potilaan hoitotoive, huolet ja tiedontarpeet", sv: "Patientens behandlingsönskemål, oro och informationsbehov", no: "Pasientens behandlingspreferanse, bekymringer og informasjonsbehov", da: "Patientens behandlingspræference, bekymringer og informationsbehov", is: "Óskir sjúklings um meðferð, áhyggjur og upplýsingaþörf" },
    "f.participants": { en: "MDT participants", fi: "MDT-osallistujat", sv: "MDK-deltagare", no: "MDT-deltakere", da: "MDT-deltagere", is: "MDT-þátttakendur" },
    "f.furtherInv": { en: "Further investigations recommended", fi: "Suositellut jatkotutkimukset", sv: "Rekommenderade ytterligare undersökningar", no: "Anbefalte videre undersøkelser", da: "Anbefalede yderligere undersøgelser", is: "Frekari rannsóknir sem mælt er með" },
    "f.cTNM2": { en: "c2-TNM after MDT", fi: "c2-TNM MDT:n jälkeen", sv: "c2-TNM efter MDK", no: "c2-TNM etter MDT", da: "c2-TNM efter MDT", is: "c2-TNM eftir MDT" },
    "f.intent": { en: "Treatment intent", fi: "Hoidon tavoite", sv: "Behandlingsintention", no: "Behandlingsintensjon", da: "Behandlingsintention", is: "Markmið meðferðar" },
    "f.surgery": { en: "Surgery or bronchoscopic procedures", fi: "Leikkaus tai bronkoskooppiset toimenpiteet", sv: "Kirurgi eller bronkoskopiska ingrepp", no: "Kirurgi eller bronkoskopiske prosedyrer", da: "Kirurgi eller bronkoskopiske procedurer", is: "Skurðaðgerð eða berkjuspeglunaraðgerðir" },
    "f.onco": { en: "Oncological drug therapy", fi: "Onkologinen lääkehoito", sv: "Onkologisk läkemedelsbehandling", no: "Onkologisk legemiddelbehandling", da: "Onkologisk medicinsk behandling", is: "Krabbameinslyfjameðferð" },
    "f.rt": { en: "Radiotherapy", fi: "Sädehoito", sv: "Strålbehandling", no: "Strålebehandling", da: "Strålebehandling", is: "Geislameðferð" },
    "f.symptom": { en: "Symptom care and supportive care", fi: "Oireenmukainen ja tukihoito", sv: "Symtomlindring och stödjande vård", no: "Symptomlindring og støttebehandling", da: "Symptombehandling og understøttende behandling", is: "Einkenna- og stuðningsmeðferð" },

    // ---- hints ----
    "h.quitYears": { en: "if former smoker", fi: "jos entinen tupakoitsija", sv: "om före detta rökare", no: "hvis tidligere røyker", da: "hvis tidligere ryger", is: "ef fyrrum reykingamaður" },
    "h.bmi": { en: "auto-calculated", fi: "lasketaan automaattisesti", sv: "beräknas automatiskt", no: "beregnes automatisk", da: "beregnes automatisk", is: "reiknað sjálfkrafa" },
    "h.g8": { en: "geriatric screening, 0 to 17", fi: "geriatrinen seulonta, 0–17", sv: "geriatrisk screening, 0–17", no: "geriatrisk screening, 0–17", da: "geriatrisk screening, 0–17", is: "öldrunarskimun, 0–17" },
    "h.anticoag": { en: "drug name, indication, pausing feasibility if relevant", fi: "lääkkeen nimi, indikaatio, tauotusmahdollisuus tarvittaessa", sv: "läkemedelsnamn, indikation, möjlighet att pausa vid behov", no: "legemiddelnavn, indikasjon, mulighet for pause ved behov", da: "lægemiddelnavn, indikation, mulighed for pause hvis relevant", is: "lyfjaheiti, ábending, möguleiki á hléi ef við á" },
    "h.diagSample": { en: "site, method, date if useful", fi: "kohde, menetelmä, päivämäärä tarvittaessa", sv: "lokal, metod, datum vid behov", no: "sted, metode, dato ved behov", da: "lokalisation, metode, dato hvis nyttigt", is: "staður, aðferð, dagsetning ef gagnlegt" },
    "h.pdl1": { en: "numeric only, not positive / high / low", fi: "vain numero, ei positiivinen / korkea / matala", sv: "endast numeriskt, inte positiv / hög / låg", no: "kun numerisk, ikke positiv / høy / lav", da: "kun numerisk, ikke positiv / høj / lav", is: "aðeins tölulegt, ekki jákvætt / hátt / lágt" },
    "h.otherImaging": { en: "method + date + main findings", fi: "menetelmä + päivämäärä + päälöydökset", sv: "metod + datum + huvudfynd", no: "metode + dato + hovedfunn", da: "metode + dato + hovedfund", is: "aðferð + dagsetning + helstu fundir" },
    "h.lungfn": { en: "value, %, z-score", fi: "arvo, %, z-arvo", sv: "värde, %, z-värde", no: "verdi, %, z-skår", da: "værdi, %, z-score", is: "gildi, %, z-gildi" },

    // ---- generic option labels ----
    "o.select": { en: "Select", fi: "Valitse", sv: "Välj", no: "Velg", da: "Vælg", is: "Velja" },
    "o.female": { en: "Female", fi: "Nainen", sv: "Kvinna", no: "Kvinne", da: "Kvinde", is: "Kona" },
    "o.male": { en: "Male", fi: "Mies", sv: "Man", no: "Mann", da: "Mand", is: "Karl" },
    "o.otherUnspecified": { en: "Other / not specified", fi: "Muu / ei määritelty", sv: "Annat / ej angivet", no: "Annet / ikke angitt", da: "Andet / ikke angivet", is: "Annað / ótilgreint" },
    "o.never": { en: "Never smoker", fi: "Ei koskaan tupakoinut", sv: "Aldrig rökare", no: "Aldri røyker", da: "Aldrig ryger", is: "Aldrei reykt" },
    "o.former": { en: "Former smoker", fi: "Entinen tupakoitsija", sv: "Före detta rökare", no: "Tidligere røyker", da: "Tidligere ryger", is: "Fyrrum reykingamaður" },
    "o.current": { en: "Current smoker", fi: "Nykyinen tupakoitsija", sv: "Nuvarande rökare", no: "Nåværende røyker", da: "Nuværende ryger", is: "Reykir núna" },
    "o.ecog0": { en: "0, fully active", fi: "0, täysin aktiivinen", sv: "0, fullt aktiv", no: "0, fullt aktiv", da: "0, fuldt aktiv", is: "0, fullkomlega virk(ur)" },
    "o.ecog1": { en: "1, restricted strenuous activity, ambulatory", fi: "1, rajoittunut rasittava toiminta, liikkuva", sv: "1, begränsad ansträngande aktivitet, uppegående", no: "1, begrenset anstrengende aktivitet, oppegående", da: "1, begrænset anstrengende aktivitet, oppegående", is: "1, takmörkuð erfið virkni, á ferli" },
    "o.ecog2": { en: "2, ambulatory, self-care, less than 50% in bed", fi: "2, liikkuva, omatoiminen, alle 50 % vuoteessa", sv: "2, uppegående, självhjälp, mindre än 50% i säng", no: "2, oppegående, selvhjulpen, mindre enn 50% i seng", da: "2, oppegående, selvhjulpen, mindre end 50% i seng", is: "2, á ferli, sjálfbjarga, minna en 50% í rúmi" },
    "o.ecog3": { en: "3, limited self-care, more than 50% in bed", fi: "3, rajoittunut omatoimisuus, yli 50 % vuoteessa", sv: "3, begränsad självhjälp, mer än 50% i säng", no: "3, begrenset selvhjulpenhet, mer enn 50% i seng", da: "3, begrænset selvhjælp, mere end 50% i seng", is: "3, takmörkuð sjálfbjörg, meira en 50% í rúmi" },
    "o.ecog4": { en: "4, completely disabled, bedridden", fi: "4, täysin toimintakyvytön, vuodepotilas", sv: "4, helt oförmögen, sängliggande", no: "4, helt hjelpetrengende, sengeliggende", da: "4, helt hjælpeløs, sengeliggende", is: "4, algjörlega ófær, rúmliggjandi" },
    "o.thorax": { en: "Thorax", fi: "Thorax", sv: "Torax", no: "Toraks", da: "Toraks", is: "Brjósthol" },
    "o.thoraxUpperAbd": { en: "Thorax + upper abdomen", fi: "Thorax + ylävatsa", sv: "Torax + övre buk", no: "Toraks + øvre abdomen", da: "Toraks + øvre abdomen", is: "Brjósthol + efri kviður" },
    "o.thoraxAbd": { en: "Thorax + abdomen", fi: "Thorax + vatsa", sv: "Torax + buk", no: "Toraks + abdomen", da: "Toraks + abdomen", is: "Brjósthol + kviður" },
    "o.other": { en: "Other", fi: "Muu", sv: "Annat", no: "Annet", da: "Andet", is: "Annað" },
    "o.contrastEnhanced": { en: "Contrast-enhanced", fi: "Varjoainetehosteinen", sv: "Kontrastförstärkt", no: "Kontrastforsterket", da: "Kontrastforstærket", is: "Skuggaefnisaukin" },
    "o.nonContrast": { en: "Non-contrast", fi: "Ilman varjoainetta", sv: "Utan kontrast", no: "Uten kontrast", da: "Uden kontrast", is: "Án skuggaefnis" },
    "o.withContrast": { en: "With contrast", fi: "Varjoaineella", sv: "Med kontrast", no: "Med kontrast", da: "Med kontrast", is: "Með skuggaefni" },
    "o.withoutContrast": { en: "Without contrast", fi: "Ilman varjoainetta", sv: "Utan kontrast", no: "Uten kontrast", da: "Uden kontrast", is: "Án skuggaefnis" },
    "o.unknown": { en: "Unknown", fi: "Ei tiedossa", sv: "Okänt", no: "Ukjent", da: "Ukendt", is: "Óþekkt" },
    "o.done": { en: "Done", fi: "Tehty", sv: "Utförd", no: "Utført", da: "Udført", is: "Lokið" },
    "o.booked": { en: "Booked", fi: "Varattu", sv: "Bokad", no: "Bestilt", da: "Bestilt", is: "Bókað" },
    "o.notIndicated": { en: "Not indicated", fi: "Ei indikoitu", sv: "Ej indicerad", no: "Ikke indisert", da: "Ikke indiceret", is: "Ekki ábending" },
    "o.notYetDone": { en: "Not yet done", fi: "Ei vielä tehty", sv: "Ännu ej utförd", no: "Ikke utført ennå", da: "Endnu ikke udført", is: "Ekki enn lokið" },
    "o.concordant": { en: "Concordant", fi: "Yhdenmukainen", sv: "Överensstämmande", no: "Samsvarende", da: "Overensstemmende", is: "Samhljóða" },
    "o.discordant": { en: "Discordant", fi: "Ristiriitainen", sv: "Ej överensstämmande", no: "Ikke samsvarende", da: "Ikke overensstemmende", is: "Ósamhljóða" },
    "o.notAssessable": { en: "Not assessable", fi: "Ei arvioitavissa", sv: "Ej bedömbar", no: "Ikke vurderbar", da: "Ikke vurderbar", is: "Ekki metanlegt" },
    "o.mriBrain": { en: "MRI brain", fi: "Aivojen MRI", sv: "MR hjärna", no: "MR hjerne", da: "MR hjerne", is: "Segulómun heila" },
    "o.ctBrain": { en: "CT brain", fi: "Aivojen TT", sv: "DT hjärna", no: "CT hjerne", da: "CT hjerne", is: "TS heila" },
    "o.notDone": { en: "Not done", fi: "Ei tehty", sv: "Ej utförd", no: "Ikke utført", da: "Ikke udført", is: "Ekki gert" },
    "o.yes": { en: "Yes", fi: "Kyllä", sv: "Ja", no: "Ja", da: "Ja", is: "Já" },
    "o.no": { en: "No", fi: "Ei", sv: "Nej", no: "Nei", da: "Nej", is: "Nei" },
    "o.planned": { en: "Planned", fi: "Suunniteltu", sv: "Planerad", no: "Planlagt", da: "Planlagt", is: "Áætlað" },
    "o.unclear": { en: "Unclear", fi: "Epäselvä", sv: "Oklart", no: "Uklart", da: "Uklart", is: "Óljóst" },
    "o.curative": { en: "Curative", fi: "Kuratiivinen", sv: "Kurativ", no: "Kurativ", da: "Kurativ", is: "Læknandi" },
    "o.potentiallyCurative": { en: "Potentially curative after further staging", fi: "Mahdollisesti kuratiivinen lisälevinneisyysmäärityksen jälkeen", sv: "Potentiellt kurativ efter ytterligare stadieindelning", no: "Potensielt kurativ etter videre stadieinndeling", da: "Potentielt kurativ efter yderligere stadieinddeling", is: "Mögulega læknandi eftir frekari stigun" },
    "o.lifeProlonging": { en: "Life-prolonging palliative", fi: "Elämää pidentävä palliatiivinen", sv: "Livsförlängande palliativ", no: "Livsforlengende palliativ", da: "Livsforlængende palliativ", is: "Lífslengjandi líknandi" },
    "o.symptomPalliative": { en: "Symptom-directed palliative", fi: "Oireisiin kohdistuva palliatiivinen", sv: "Symtomriktad palliativ", no: "Symptomrettet palliativ", da: "Symptomrettet palliativ", is: "Einkennamiðuð líknandi" },
    "o.bsc": { en: "Best supportive care", fi: "Paras tukihoito", sv: "Bästa understödjande vård", no: "Beste støttebehandling", da: "Bedste understøttende behandling", is: "Besta stuðningsmeðferð" },
    "o.intentUnclear": { en: "Unclear, further information needed", fi: "Epäselvä, lisätietoa tarvitaan", sv: "Oklart, mer information behövs", no: "Uklart, mer informasjon nødvendig", da: "Uklart, yderligere information nødvendig", is: "Óljóst, frekari upplýsinga þörf" },

    // ---- comorbidity checkbox options (structured mini) ----
    "cm.copd": { en: "COPD", fi: "Keuhkoahtaumatauti", sv: "KOL", no: "KOLS", da: "KOL", is: "Langvinn lungnateppa" },
    "cm.asthma": { en: "Asthma", fi: "Astma", sv: "Astma", no: "Astma", da: "Astma", is: "Astmi" },
    "cm.ild": { en: "ILD / pulmonary fibrosis", fi: "ILD / keuhkofibroosi", sv: "ILD / lungfibros", no: "ILD / lungefibrose", da: "ILD / lungefibrose", is: "Millivefslungnasjúkdómur / lungnatrefjun" },
    "cm.cvd": { en: "Cardiovascular disease", fi: "Sydän- ja verisuonisairaus", sv: "Hjärt-kärlsjukdom", no: "Hjerte- og karsykdom", da: "Hjerte-kar-sygdom", is: "Hjarta- og æðasjúkdómur" },
    "cm.autoimmune": { en: "Autoimmune disease", fi: "Autoimmuunisairaus", sv: "Autoimmun sjukdom", no: "Autoimmun sykdom", da: "Autoimmun sygdom", is: "Sjálfsofnæmissjúkdómur" },
    "cm.diabetes": { en: "Diabetes", fi: "Diabetes", sv: "Diabetes", no: "Diabetes", da: "Diabetes", is: "Sykursýki" },
    "cm.renal": { en: "Renal disease", fi: "Munuaissairaus", sv: "Njursjukdom", no: "Nyresykdom", da: "Nyresygdom", is: "Nýrnasjúkdómur" },
    "cm.otherText": { en: "Other comorbidities (specify)", fi: "Muut liitännäissairaudet (tarkenna)", sv: "Annan samsjuklighet (ange)", no: "Annen komorbiditet (spesifiser)", da: "Anden komorbiditet (angiv)", is: "Aðrir fylgisjúkdómar (tilgreina)" },

    // ---- histology options (structured mini) ----
    "hist.adeno": { en: "Adenocarcinoma", fi: "Adenokarsinooma", sv: "Adenokarcinom", no: "Adenokarsinom", da: "Adenokarcinom", is: "Kirtilkrabbamein" },
    "hist.squamous": { en: "Squamous cell carcinoma", fi: "Levyepiteelikarsinooma", sv: "Skivepitelcancer", no: "Plateepitelkarsinom", da: "Planocellulært karcinom", is: "Flöguþekjukrabbamein" },
    "hist.sclc": { en: "Small cell carcinoma", fi: "Pienisoluinen karsinooma", sv: "Småcellig cancer", no: "Småcellet karsinom", da: "Småcellet karcinom", is: "Smáfrumukrabbamein" },
    "hist.nsclcNos": { en: "NSCLC, not otherwise specified", fi: "Ei-pienisoluinen, tarkemmin määrittelemätön", sv: "Icke-småcellig, ej närmare specificerad", no: "Ikke-småcellet, ikke nærmere spesifisert", da: "Ikke-småcellet, ikke nærmere specificeret", is: "Ekki-smáfrumu, ekki nánar tilgreint" },
    "hist.otherPending": { en: "Other / pending", fi: "Muu / kesken", sv: "Annat / pågående", no: "Annet / venter", da: "Andet / afventer", is: "Annað / í bið" },

    // ---- biomarker status options (structured mini) ----
    "bm.notTested": { en: "Not tested", fi: "Ei testattu", sv: "Ej testad", no: "Ikke testet", da: "Ikke testet", is: "Ekki prófað" },
    "bm.negative": { en: "Negative", fi: "Negatiivinen", sv: "Negativ", no: "Negativ", da: "Negativ", is: "Neikvætt" },
    "bm.positive": { en: "Positive", fi: "Positiivinen", sv: "Positiv", no: "Positiv", da: "Positiv", is: "Jákvætt" },
    "bm.pending": { en: "Pending", fi: "Kesken", sv: "Pågående", no: "Venter", da: "Afventer", is: "Í bið" },
    "f.molecular": { en: "Molecular alterations", fi: "Molekyylimuutokset", sv: "Molekylära förändringar", no: "Molekylære endringer", da: "Molekylære forandringer", is: "Sameindabreytingar" },
    "f.detail": { en: "Detail / subtype", fi: "Tarkenne / alatyyppi", sv: "Detalj / subtyp", no: "Detalj / subtype", da: "Detalje / subtype", is: "Nánar / undirgerð" },

    // ---- expanded molecular / histology / staging / treatment (clinical review 2025) ----
    "f.drivers": { en: "Driver alterations (actionable)", fi: "Ajurimuutokset (targetoitavat)", sv: "Drivarförändringar (targeterbara)", no: "Driverendringer (targeterbare)", da: "Driverforandringer (targeterbare)", is: "Drífandi breytingar (mörkanlegar)" },
    "f.ioResistance": { en: "Immunotherapy / resistance markers", fi: "Immunoterapia- / resistenssimarkkerit", sv: "Immunterapi- / resistensmarkörer", no: "Immunterapi- / resistensmarkører", da: "Immunterapi- / resistensmarkører", is: "Ónæmismeðferðar- / mótstöðumarkerar" },
    "f.nrg1": { en: "NRG1 fusion", fi: "NRG1-fuusio", sv: "NRG1-fusion", no: "NRG1-fusjon", da: "NRG1-fusion", is: "NRG1-samruni" },
    "f.stk11": { en: "STK11 / LKB1", fi: "STK11 / LKB1", sv: "STK11 / LKB1", no: "STK11 / LKB1", da: "STK11 / LKB1", is: "STK11 / LKB1" },
    "f.keap1": { en: "KEAP1", fi: "KEAP1", sv: "KEAP1", no: "KEAP1", da: "KEAP1", is: "KEAP1" },
    "f.smarca4": { en: "SMARCA4", fi: "SMARCA4", sv: "SMARCA4", no: "SMARCA4", da: "SMARCA4", is: "SMARCA4" },
    "f.tmb": { en: "TMB (mut/Mb)", fi: "TMB (mut/Mb)", sv: "TMB (mut/Mb)", no: "TMB (mut/Mb)", da: "TMB (mut/Mb)", is: "TMB (mut/Mb)" },
    "f.msi": { en: "MSI / MMR status", fi: "MSI / MMR -status", sv: "MSI / MMR-status", no: "MSI / MMR-status", da: "MSI / MMR-status", is: "MSI / MMR-staða" },
    "f.testMethod": { en: "Molecular testing method", fi: "Molekyylitestausmenetelmä", sv: "Molekylär testmetod", no: "Molekylær testmetode", da: "Molekylær testmetode", is: "Sameindaprófunaraðferð" },
    "f.sampleType": { en: "Molecular sample type", fi: "Molekyylinäytteen tyyppi", sv: "Molekylär provtyp", no: "Molekylær prøvetype", da: "Molekylær prøvetype", is: "Gerð sameindasýnis" },
    "h.molecularSubtypes": { en: "Specify actionable subtypes: KRAS G12C, EGFR exon 20 ins, MET exon 14 skipping or amplification, ERBB2 exon 20.", fi: "Tarkenna targetoitavat alatyypit: KRAS G12C, EGFR exon 20 ins, MET exon 14 skipping tai amplifikaatio, ERBB2 exon 20.", sv: "Ange targeterbara subtyper: KRAS G12C, EGFR exon 20 ins, MET exon 14 skipping eller amplifiering, ERBB2 exon 20.", no: "Angi targeterbare subtyper: KRAS G12C, EGFR exon 20 ins, MET exon 14 skipping eller amplifikasjon, ERBB2 exon 20.", da: "Angiv targeterbare subtyper: KRAS G12C, EGFR exon 20 ins, MET exon 14 skipping eller amplifikation, ERBB2 exon 20.", is: "Tilgreindu mörkanlegar undirgerðir: KRAS G12C, EGFR exon 20 ins, MET exon 14 skipping eða mögnun, ERBB2 exon 20." },

    "hist.largeCell": { en: "Large cell carcinoma", fi: "Suurisoluinen karsinooma", sv: "Storcellig cancer", no: "Storcellet karsinom", da: "Storcellet karcinom", is: "Stórfrumukrabbamein" },
    "hist.lcnec": { en: "LCNEC (large cell neuroendocrine)", fi: "LCNEC (suurisoluinen neuroendokriininen)", sv: "LCNEC (storcellig neuroendokrin)", no: "LCNEC (storcellet nevroendokrin)", da: "LCNEC (storcellet neuroendokrin)", is: "LCNEC (stórfrumu taugainnkirtla)" },
    "hist.carcinoidTypical": { en: "Carcinoid, typical", fi: "Karsinoidi, tyypillinen", sv: "Karcinoid, typisk", no: "Karsinoid, typisk", da: "Karcinoid, typisk", is: "Karsínóíð, dæmigert" },
    "hist.carcinoidAtypical": { en: "Carcinoid, atypical", fi: "Karsinoidi, atyyppinen", sv: "Karcinoid, atypisk", no: "Karsinoid, atypisk", da: "Karcinoid, atypisk", is: "Karsínóíð, ódæmigert" },
    "hist.adenosquamous": { en: "Adenosquamous carcinoma", fi: "Adenoskvamoosinen karsinooma", sv: "Adenoskvamös cancer", no: "Adenoskvamøst karsinom", da: "Adenoskvamøst karcinom", is: "Kirtilflöguþekjukrabbamein" },
    "hist.sarcomatoid": { en: "Sarcomatoid carcinoma", fi: "Sarkomatoidinen karsinooma", sv: "Sarkomatoid cancer", no: "Sarkomatoid karsinom", da: "Sarkomatoid karcinom", is: "Sarkmyndað krabbamein" },
    "hist.mesothelioma": { en: "Pleural mesothelioma", fi: "Keuhkopussin mesoteliooma", sv: "Pleuralt mesoteliom", no: "Pleuralt mesoteliom", da: "Pleuralt mesoteliom", is: "Fleiðrumesóþelíóm" },

    "o.mss": { en: "MSS / pMMR", fi: "MSS / pMMR", sv: "MSS / pMMR", no: "MSS / pMMR", da: "MSS / pMMR", is: "MSS / pMMR" },
    "o.msih": { en: "MSI-H / dMMR", fi: "MSI-H / dMMR", sv: "MSI-H / dMMR", no: "MSI-H / dMMR", da: "MSI-H / dMMR", is: "MSI-H / dMMR" },
    "o.ngsPanel": { en: "NGS panel", fi: "NGS-paneeli", sv: "NGS-panel", no: "NGS-panel", da: "NGS-panel", is: "NGS-panell" },
    "o.singleGene": { en: "Single-gene / hotspot", fi: "Yksittäisgeeni / hotspot", sv: "Enstaka gen / hotspot", no: "Enkeltgen / hotspot", da: "Enkeltgen / hotspot", is: "Stakt gen / hotspot" },
    "o.ihcFish": { en: "IHC / FISH only", fi: "Vain IHC / FISH", sv: "Endast IHC / FISH", no: "Kun IHC / FISH", da: "Kun IHC / FISH", is: "Aðeins IHC / FISH" },
    "o.tissue": { en: "Tissue", fi: "Kudos", sv: "Vävnad", no: "Vev", da: "Væv", is: "Vefur" },
    "o.plasma": { en: "Plasma / ctDNA", fi: "Plasma / ctDNA", sv: "Plasma / ctDNA", no: "Plasma / ctDNA", da: "Plasma / ctDNA", is: "Plasma / ctDNA" },
    "o.both": { en: "Tissue + plasma", fi: "Kudos + plasma", sv: "Vävnad + plasma", no: "Vev + plasma", da: "Væv + plasma", is: "Vefur + plasma" },

    "f.tnmEdition": { en: "TNM edition", fi: "TNM-painos", sv: "TNM-upplaga", no: "TNM-utgave", da: "TNM-udgave", is: "TNM-útgáfa" },
    "o.tnm8": { en: "8th edition (2017)", fi: "8. painos (2017)", sv: "8:e upplagan (2017)", no: "8. utgave (2017)", da: "8. udgave (2017)", is: "8. útgáfa (2017)" },
    "o.tnm9": { en: "9th edition (2024)", fi: "9. painos (2024)", sv: "9:e upplagan (2024)", no: "9. utgave (2024)", da: "9. udgave (2024)", is: "9. útgáfa (2024)" },
    "h.tnm9": { en: "9th ed.: N2 splits into N2a/N2b; M1c into M1c1/M1c2.", fi: "9. painos: N2 jakautuu N2a/N2b; M1c → M1c1/M1c2.", sv: "9:e uppl.: N2 delas i N2a/N2b; M1c i M1c1/M1c2.", no: "9. utg.: N2 deles i N2a/N2b; M1c i M1c1/M1c2.", da: "9. udg.: N2 deles i N2a/N2b; M1c i M1c1/M1c2.", is: "9. útg.: N2 skiptist í N2a/N2b; M1c í M1c1/M1c2." },

    "h.onco": { en: "e.g. neoadjuvant / perioperative immunotherapy, adjuvant osimertinib (ADAURA), consolidation durvalumab (PACIFIC); note trial eligibility", fi: "esim. neoadjuvantti / perioperatiivinen immunoterapia, adjuvantti osimertinibi (ADAURA), konsolidaatio durvalumabi (PACIFIC); merkitse tutkimuskelpoisuus", sv: "t.ex. neoadjuvant / perioperativ immunterapi, adjuvant osimertinib (ADAURA), konsolidering durvalumab (PACIFIC); ange studielämplighet", no: "f.eks. neoadjuvant / perioperativ immunterapi, adjuvant osimertinib (ADAURA), konsolidering durvalumab (PACIFIC); angi studieegnethet", da: "f.eks. neoadjuverende / perioperativ immunterapi, adjuverende osimertinib (ADAURA), konsolidering durvalumab (PACIFIC); angiv forsøgsegnethed", is: "t.d. for-/umaðgerðar ónæmismeðferð, viðbótar osimertinib (ADAURA), festingar durvalumab (PACIFIC); skráðu hæfi í rannsóknir" },
    "h.rt": { en: "e.g. chemoradiation, definitive or palliative, SABR for early-stage / oligometastatic; target and fractionation", fi: "esim. kemosädehoito, kuratiivinen tai palliatiivinen, SABR varhaisvaiheen / oligometastaattiseen; kohde ja fraktiointi", sv: "t.ex. kemoradioterapi, kurativ eller palliativ, SABR vid tidigt stadium / oligometastas; målvolym och fraktionering", no: "f.eks. kjemoradioterapi, kurativ eller palliativ, SABR ved tidlig stadium / oligometastase; målvolum og fraksjonering", da: "f.eks. kemoradioterapi, kurativ eller palliativ, SABR ved tidligt stadium / oligometastase; målvolumen og fraktionering", is: "t.d. lyfja-geislameðferð, læknandi eða líknandi, SABR við snemmstig / fámeinvörp; markmið og bútun" },
    "h.surgery": { en: "lobectomy / segmentectomy, bronchoscopic procedures, stents if relevant", fi: "lobektomia / segmentektomia, bronkoskooppiset toimenpiteet, stentit tarvittaessa", sv: "lobektomi / segmentektomi, bronkoskopiska ingrepp, stentar vid behov", no: "lobektomi / segmentektomi, bronkoskopiske prosedyrer, stenter ved behov", da: "lobektomi / segmentektomi, bronkoskopiske procedurer, stents hvis relevant", is: "blaðnám / hlutanám, berkjuspeglunaraðgerðir, stoðnet ef við á" },

    // ---- buttons ----
    "btn.summary": { en: "Generate summary", fi: "Luo yhteenveto", sv: "Skapa sammanfattning", no: "Lag sammendrag", da: "Generér resumé", is: "Búa til samantekt" },
    "btn.print": { en: "Print / save as PDF", fi: "Tulosta / tallenna PDF", sv: "Skriv ut / spara som PDF", no: "Skriv ut / lagre som PDF", da: "Udskriv / gem som PDF", is: "Prenta / vista sem PDF" },
    "btn.copy": { en: "Copy summary to clipboard", fi: "Kopioi yhteenveto leikepöydälle", sv: "Kopiera sammanfattning till urklipp", no: "Kopier sammendrag til utklippstavle", da: "Kopiér resumé til udklipsholder", is: "Afrita samantekt á klippiborð" },
    "btn.clear": { en: "Clear all", fi: "Tyhjennä kaikki", sv: "Rensa allt", no: "Tøm alt", da: "Ryd alt", is: "Hreinsa allt" },
    "msg.copied": { en: "Summary copied to clipboard.", fi: "Yhteenveto kopioitu leikepöydälle.", sv: "Sammanfattning kopierad till urklipp.", no: "Sammendrag kopiert til utklippstavle.", da: "Resumé kopieret til udklipsholder.", is: "Samantekt afrituð á klippiborð." },
    "msg.missing": { en: "Missing important fields:", fi: "Puuttuvat tärkeät kentät:", sv: "Saknade viktiga fält:", no: "Manglende viktige felt:", da: "Manglende vigtige felter:", is: "Vantar mikilvæga reiti:" },

    // ---- summary headers ----
    "sum.title": { en: "LUNG CANCER MDT CHECKLIST", fi: "KEUHKOSYÖVÄN MDT-MUISTILISTA", sv: "LUNGCANCER MDK-CHECKLISTA", no: "LUNGEKREFT MDT-SJEKKLISTE", da: "LUNGEKRÆFT MDT-TJEKLISTE", is: "LUNGNAKRABBAMEIN MDT-GÁTLISTI" },
    "sum.note": { en: "Educational structured summary. Verify in local clinical system before use.", fi: "Opetuksellinen strukturoitu yhteenveto. Tarkista paikallisessa kliinisessä järjestelmässä ennen käyttöä.", sv: "Pedagogisk strukturerad sammanfattning. Verifiera i lokalt kliniskt system före användning.", no: "Pedagogisk strukturert sammendrag. Verifiser i lokalt klinisk system før bruk.", da: "Pædagogisk struktureret resumé. Verificér i lokalt klinisk system før brug.", is: "Skipulögð samantekt til kennslu. Staðfestu í staðbundnu klínísku kerfi fyrir notkun." }
  };

  function getLang() {
    try {
      var saved = localStorage.getItem("mdtLang");
      if (saved && LANGS.indexOf(saved) >= 0) return saved;
    } catch (e) {}
    var nav = (global.navigator && (navigator.language || "")).slice(0, 2).toLowerCase();
    if (nav === "nb" || nav === "nn") nav = "no";
    return LANGS.indexOf(nav) >= 0 ? nav : "en";
  }

  function t(id, lang) {
    lang = lang || current;
    var e = S[id];
    if (!e) return id;
    return e[lang] || e.en || id;
  }

  var current = "en";

  function apply(lang) {
    current = LANGS.indexOf(lang) >= 0 ? lang : "en";
    document.documentElement.lang = current;
    try { localStorage.setItem("mdtLang", current); } catch (e) {}

    var els = document.querySelectorAll("[data-i18n]");
    for (var i = 0; i < els.length; i++) {
      els[i].textContent = t(els[i].getAttribute("data-i18n"), current);
    }
    var phs = document.querySelectorAll("[data-i18n-ph]");
    for (var j = 0; j < phs.length; j++) {
      phs[j].setAttribute("placeholder", t(phs[j].getAttribute("data-i18n-ph"), current));
    }
    global.dispatchEvent(new CustomEvent("mdt:langchange", { detail: { lang: current } }));
  }

  function init(selectEl) {
    if (selectEl && !selectEl.options.length) {
      LANGS.forEach(function (l) {
        var o = document.createElement("option");
        o.value = l; o.textContent = LANG_NAMES[l];
        selectEl.appendChild(o);
      });
    }
    current = getLang();
    if (selectEl) {
      selectEl.value = current;
      selectEl.addEventListener("change", function () { apply(selectEl.value); });
    }
    apply(current);
  }

  global.MDTI18N = {
    langs: LANGS, names: LANG_NAMES, strings: S,
    t: t, apply: apply, init: init,
    get current() { return current; }
  };
})(window);
