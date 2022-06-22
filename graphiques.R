listpack <- c("ggplot2","cowplot","tidyverse")
needpack <- setdiff(listpack, rownames(installed.packages()))
if(length(needpack)) {
  install.packages(needpack)
}
library(easypackages)
libraries(listpack)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))



donnees <- read.csv("/media/lucile/DATADRIVE0/Documents/Recherche/GDN/RIG/data-1655384176388.csv", dec=",", quote = "\"") %>%
  dplyr::select(all_CP,all_CATEAAV2020,all_P17_POP,all_SUPERF,all_GCD,all_P_NP5CLA,
                all_HC_ARC4,all_HC_ARC3P,all_HC_ARC2P,all_HC_ARC1P,
                nb_contrib, nb_contrib_avec_trains, nb_contrib_avec_pistes_cyclables,
                all_P16_CHOM1564)
donnees %>%  dplyr::mutate(all_DENS17=all_P17_POP/all_SUPERF)

cp_donnees <- donnees %>% 
  group_by(all_CP) %>%
  summarise(sum_P17_POP=sum(all_P17_POP),
            sum_SUPERF=sum(all_SUPERF),
            sum_P16_CHOM1564 = sum(all_P16_CHOM1564),
            mean_HC_ARC4=mean(all_HC_ARC4),
            mean_HC_ARC3p=mean(all_HC_ARC3P),
            mean_HC_ARC2p=mean(all_HC_ARC2P),
            mean_HC_ARC1p=mean(all_HC_ARC1P),
            nb_contrib=mean(nb_contrib),
            nb_contrib_avec_trains=mean(nb_contrib_avec_trains),
            nb_contrib_avec_pistes_cyclables=mean(nb_contrib_avec_pistes_cyclables)
            ) %>% 
  mutate(pct_trains=100*nb_contrib_avec_trains/nb_contrib,
         pct_pistes_cyclables=100*nb_contrib_avec_pistes_cyclables/nb_contrib)%>%
  dplyr::mutate(DENS17=log(sum_P17_POP/sum_SUPERF)) %>%
  dplyr::mutate(TAUXCHOM = sum_P16_CHOM1564/sum_P17_POP)

box <- function(xvar,xlab,xpng) {

  x1 <- cp_donnees[,xvar]
  x2 <- cp_donnees[cp_donnees$nb_contrib!=0,xvar]
  x3 <- cp_donnees[cp_donnees$nb_contrib_avec_trains!=0,xvar]
  x4 <- cp_donnees[cp_donnees$nb_contrib_avec_pistes_cyclables!=0,xvar]
  
  f1 <- rep(c('Ensemble des zones postales'),length(x1))
  f2 <- rep(c('Zones postales avec contributeurs'),length(x2))
  f3 <- rep(c('Zones postales avec demande de trains'),length(x3))
  f4 <- rep(c('Zones postales avec demande de pistes cyclables'),length(x4))
  
  t1 <- data.frame(x1,f1)
  names(t1)<-c('var','group')
  t2 <- data.frame(x2,f2)
  names(t2)<-c('var','group')
  t3 <- data.frame(x3,f3)
  names(t3)<-c('var','group')
  t4 <- data.frame(x4,f4)
  names(t4)<-c('var','group')
  tab <- rbind(t1,t2,t3,t4)
  
  png(xpng, width = 600)
  p <- ggplot(tab, aes(group, var)) + 
    geom_boxplot() + 
    stat_summary(fun=mean, geom="point", shape=18, size=1.5, color="red", fill="grey") +
    coord_flip() +
    xlab("") + ylab(xlab) 
  dev.off()
  print(p)
}


box(xvar="mean_HC_ARC4",
    xlab="Temps de trajet vers le centre majeur le plus proche (minutes)",
    xpng="/home/lucile/Téléchargements/BOXPLOT_HC_ARC4.png")

box(xvar="mean_HC_ARC3p",
    xlab="Temps de trajet vers le centre structurant le plus proche (minutes)",
    xpng="BOXPLOT_HC_ARC3P.png")

box(xvar="mean_HC_ARC2p",
    xlab="Temps de trajet vers le centre intermediaire le plus proche (minutes)",
    xpng="BOXPLOT_HC_ARC2P.png")

box(xvar="mean_HC_ARC1p",
    xlab="Temps de trajet vers le centre local le plus proche (minutes)",
    xpng="BOXPLOT_HC_ARC1P.png")

box(xvar="DENS17",
    xlab="Densité de population en 2017 (échelle log)",
    xpng="BOXPLOT_DENS17.png")

box(xvar="TAUXCHOM",
    xlab="Taux de chômage en 2016",
    xpng="BOXPLOT_DENS17.png")
