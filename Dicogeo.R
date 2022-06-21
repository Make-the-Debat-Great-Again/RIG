## Grand Débat National
## Nomenclatures géographiques des communes

listpack <- c("sf","data.table","tidyverse","readxl","openxlsx")

needpack <- setdiff(listpack, rownames(installed.packages()))
if(length(needpack)) {
  install.packages(needpack)
}
library(easypackages)
libraries(listpack)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#Chargement des aires d'attraction des villes - Table

url <-"https://www.insee.fr/fr/statistiques/fichier/4803954/AAV2020_au_01-01-2020.zip"

temp <- tempfile()
temp2 <- tempfile()

download.file(url, temp)
unzip(zipfile = temp, exdir = temp2)

dAAV2020 <- data.frame(read_excel(file.path(temp2, "AAV2020_au_01-01-2020_v1.xlsx"),sheet = 'Composition_communale',skip=5))
dAAV2020 <- dAAV2020 %>%
    dplyr::select(DEPCOM=CODGEO,LIBGEO,AAV2020,LIBAAV2020,CATEAAV2020,DEP,REG)

#Chargement des bassins de vie

#url<-"https://www.insee.fr/fr/statistiques/fichier/2115016/BV2012_au_01-01-2020.zip"
url<-"https://www.insee.fr/fr/statistiques/fichier/2115016/BV2012_au_01-01-2020_v1.zip"

temp <- tempfile()
temp2 <- tempfile()

download.file(url, temp)
unzip(zipfile = temp, exdir = temp2)

dBV2012 <- data.frame(read_excel(file.path(temp2, "BV2012_au_01-01-2020_v1.xlsx"),sheet = 'Composition_communale',skip=5))
dBV2012 <- dBV2012 %>%
  dplyr::select(DEPCOM=CODGEO,LIBGEO,BV2012,LIBBV2012,DEP,REG)

url <- "https://www.insee.fr/fr/statistiques/fichier/4515941/base-ccc-serie-historique-2017.zip"

temp <- tempfile()
temp2 <- tempfile()

download.file(url, temp)
unzip(zipfile = temp, exdir = temp2)

fadr<-file.path(temp2,"base-cc-serie-historique-2017.CSV")
inseehist <-data.frame(read_delim(fadr,delim=";",col_names=TRUE))

inseehist <- inseehist %>%
  dplyr::select(DEPCOM=CODGEO,P17_POP,D75_POP,SUPERF,P17_LOG,P17_RP,P17_RSECOCC,P17_LOGVAC,P17_PMEN)
  

fadr<-file.path(temp2,"meta_base-cc-serie-historique-2017.CSV")
inseehist_meta <-data.frame(read_delim(fadr,delim=";",col_names=TRUE))

inseehist_meta <-inseehist_meta[1:63,]
inseehist_meta <- inseehist_meta %>%
  filter(COD_VAR %in% c("CODGEO","P17_POP","D75_POP","SUPERF","P17_LOG","P17_RP","P17_RSECOCC","P17_LOGVAC","P17_PMEN"))

Centralites <- read_excel("E:/users/_owncloud/inra/Centralites/Livrables/Rapport final/web/202009_Data_EtudesCentralités_INRAE_ANCT.xlsx",sheet = 'Table')
Centralites <- Centralites %>%
  dplyr::select(DEPCOM=DC,EPCI,
         DC_UU,
         GCD,
         P_NP5CLA,
         Tag_Centralite,
         DC_ARC4,
         HC_ARC4,
         DC_REPORT_ARC4,
         HC_REPORT_ARC4,
         DC_ARC3P,
         HC_ARC3P,
         DC_REPORT_ARC3P,
         HC_REPORT_ARC3P,
         DC_ARC2P,
         HC_ARC2P,
         DC_REPORT_ARC2P,
         HC_REPORT_ARC2P,
         DC_ARC1P,
         HC_ARC1P,
         DC_REPORT_ARC1P,
         HC_REPORT_ARC1P,
         DC_UU_AD4,
         DC_UU_AD3P,
         DC_UU_AD2P,
         DC_UU_AD1P,
         P16_POP,
         P06_POP,
         P16_LOG,
         P06_LOG,
         P16_RP,
         P06_RP,
         P16_RSECOCC,
         P06_RSECOCC,
         P16_LOGVAC,
         P06_LOGVAC,
         P16_EMPLT,
         P06_EMPLT,
         P16_CHOM1564,
         P16_INACT1564,
         NIV_EQUIP_2017,
  )

data_cadrage <- merge(dAAV2020,dBV2012)
data_cadrage <- merge(data_cadrage,inseehist)
data_cadrage <- merge(data_cadrage,Centralites)
data_cadrage$ARRMUN <- substr(data_cadrage$DEPCOM,1,3)

#Chargement des codes postaux

url <- "https://www.data.gouv.fr/en/datasets/r/554590ab-ae62-40ac-8353-ee75162c05ee"
dCP2015<-data.frame(read_delim(url,delim=";", col_names=TRUE,col_types = "ccccc")) #Table officielle 2015
names(dCP2015)<-c("DEPCOM","LIBCOM","CP","L5","ACHEMNT")

GPS<-data.frame(read_delim(url,delim=";", col_names=TRUE)) #Table officielle 2015
names(GPS)<-c("DEPCOM","LIBCOM","CP","L5","ACHEMNT","GPS")
GPS<-GPS %>%
  select(GPS)

GPS.split<-strsplit(GPS$GPS,split=",")
tmp<-do.call(rbind,GPS.split)

dCP2015<-data.frame(dCP2015,tmp)
names(dCP2015)<-c("DEPCOM","LIBCOM","CP","L5","ACHEMNT","latitude","longitude")
dCP2015<-dCP2015 %>%
  select(DEPCOM, LIBCOM, CP, latitude, longitude)

dCP2015 <- dCP2015 %>% distinct(DEPCOM, CP, .keep_all = TRUE)

url <- "https://www.data.gouv.fr/en/datasets/r/455b9d9f-df83-4310-9acc-d3e3e54c2110"
dCPNEW<-data.frame(read_delim(url,delim=";",col_names=TRUE)) #Communes nouvelles
dCPNEW<-dCPNEW %>%
  select(Code.INSEE.Commune.Nouvelle, Nom.Commune.Nouvelle.Siège,Adresse.2016...Code.INSEE)
names(dCPNEW)<-c("DEPCOM","LIBCOM","CP")
dCPNEW<-filter(dCPNEW, !is.na(CP))
dCPNEW<-distinct(dCPNEW, CP,.keep_all = TRUE)

### Association aux codes postaux

all <- full_join(dCP2015,data_cadrage, by="DEPCOM")
all <- all[order(all$DEPCOM),]


Index<-(all$ARRMUN=="132")
all$DEPCOM[Index] <- "13055"

Index<-(all$ARRMUN=="751")
all$DEPCOM[Index] <- "75056"

Index<-(all$ARRMUN=="693")
all$DEPCOM[Index] <- "69123"

rm(Index)

all <- all %>% distinct(CP, DEPCOM, .keep_all = TRUE)

to <- (all$DEPCOM=="16351")
dCP<-filter(all, DEPCOM=="16233")

all$LIBCOM[to]<-dCP$LIBCOM
all$CP[to]<-dCP$CP
all$latitude[to]<-dCP$latitude
all$longitude[to]<-dCP$longitude

to <- (all$DEPCOM=="53239")
dCP<-filter(all, DEPCOM=="53249")

all$LIBCOM[to]<-dCP$LIBCOM
all$CP[to]<-dCP$CP
all$latitude[to]<-dCP$latitude
all$longitude[to]<-dCP$longitude

to <- (all$DEPCOM=="53274")
dCP<-filter(all, DEPCOM=="53249")

all$LIBCOM[to]<-dCP$LIBCOM
all$CP[to]<-dCP$CP
all$latitude[to]<-dCP$latitude
all$longitude[to]<-dCP$longitude

write.csv(all, "data_cadrage.csv")

cp_aav2020 <- all %>% 
  filter(!is.na(CATEAAV2020)) %>% 
  group_by(CP, CATEAAV2020) %>% 
  summarise(SPMUN=sum(P17_POP), ) %>% 
  spread(key="CATEAAV2020",
         value=SPMUN,fill=0)
names(cp_aav2020)<-c("CP","POPAAV11","POPAAV12","POPAAV13","POPAAV20","POPAAV30")
cp_aav2020 <- data.frame(cp_aav2020)
cp_aav2020 <- cp_aav2020 %>%
  mutate(PMUN = select(., AAV11:AAV30) %>% rowSums(na.rm = TRUE))

cp_aav2020pct <- all %>% 
  filter(!is.na(CATEAAV2020)) %>% 
  group_by(CP, CATEAAV2020) %>%
  summarise(SPMUN=sum(P17_POP), ) %>% 
  mutate(pct=100*SPMUN/sum(SPMUN))%>%
  subset(select=c("CP","CATEAAV2020","pct")) %>%   #drop sum pop
  spread(key="CATEAAV2020", value=pct,fill=0)
names(cp_aav2020)<-c("CP","PCTAAV11","PCTAAV12","PCTAAV13","PCTAAV20","PCTAAV30")

cp_aav2020<-merge(cp_aav2020,cp_aav2020pct)
write.csv(cp_aav2020, "cp_aav2020.csv")

cp_maxpop <- all %>%
  select(DEPCOM,CP,P17_POP)

cp_maxpop <- arrange(cp_maxpop,CP,desc(P17_POP))
write.csv(cp_maxpop, "cp_maxpop.csv")

url <- "https://www.insee.fr/fr/statistiques/fichier/4505239/ODD_RDS.zip"
temp <- tempfile()
temp3 <- tempfile()

download.file(url, temp)
unzip(zipfile = temp, exdir = temp3)

fadr<-file.path(temp3,"ODD_COM.rds")
data_itdd<-readRDS(fadr)

url<-"https://www.insee.fr/fr/statistiques/fichier/4505239/dictionnaire_indicateurs_territoriaux_developpement_durable.xlsx"

data_itdd_meta <- data.frame(read.xlsx(url),sheet = 'dictionnaire_indicateurs_territ')
data_itdd_meta <- data_itdd_meta %>%
  drop_na(Fichier.COM)

rm(fadr,listpack,needpack,temp,temp2,temp3,url)

write.csv(data_itdd, "data_itdd.csv")
write.csv(data_itdd_meta, "data_itdd_meta.csv")


