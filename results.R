library(readr)
library(ggplot2)
library(dplyr)
library(cowplot)

#IMPORT DATA

E1 <- read_csv("E1.csv", skip = 6)
E1 <- E1[,-c(1,4,5,6,7)]
names(E1)[3] <- "a"

E1means <- summarise(group_by(E1, rr, C), 
                     ma = mean(a), sa = sd(a))

E6VR1 <- read_csv("E6RR1.csv", skip = 6)
E6VR2 <- read_csv("E6RR2.csv", skip = 6)
E6VR3 <- read_csv("E6RR3.csv", skip = 6)

E6 <- rbind(E6VR1,E6VR2,E6VR3)
E6 <- E6[,-c(1,4,6,7)]
names(E6)[4:5] <- c("ca","a")
E6$nca <- E6$a - E6$ca

eee <- summarise(group_by(E6, rr, experiment, C), 
                 mCA = mean(ca), sCA = sd(ca), mNCA = mean(nca), sNCA = sd(nca))

eee <- subset(eee, eee$rr == 2)
eee <- subset(eee, eee$C == 50)

E6means <- summarise(group_by(E6, rr, experiment, C), 
                     Sca = mean(ca / a), Snca = mean(nca / a))

Elist = list()
Elist50k = list()
for(n in c(2,3,4,5)){
  
  En <- read_csv(paste0("E",n,".csv"), skip = 6)
  En <- En[,-c(1:6,10)]
  names(En) <- c("step","ca","nca")
  
  En <- reshape2::melt(En, id.vars="step")
  
  Enmeans <- summarise(group_by(En, step, variable), 
                       m = mean(value), s = sd(value))
  Enmeans$step <- Enmeans$step + 1 
  Enmeans <- subset(Enmeans, step %in% c(1,200,400,600,800,1000,1200,1400,1600,1800,2000))
  Elist[[n]] <- Enmeans
  Elist50k[[n]] <- rbind(subset(Enmeans, step %in% c(1,2000)),
                         setNames(c(50000,"ca",eee[n-1,4],eee[n-1,5]),names(Elist[[n]])),
                         setNames(c(50000,"nca",eee[n-1,6],eee[n-1,7]),names(Elist[[n]])))
}


#PLOTS

p <- ggplot(E1means, aes(x = rr, y = ma, group = C)) +
  geom_line(aes(colour = factor(C))) +
  geom_point(aes(colour = factor(C)), size = 3) +
  geom_errorbar(aes(ymin=ma-sa, ymax=ma+sa, colour = factor(C)), width=.05) +
  ylim(0 , 102) + 
  scale_x_continuous(breaks = c(1, 2, 3)) +
  labs(x = "RR", y = "N") +
  scale_color_manual(values=c("red", "blue"), labels = c("D00","C00")) +
  theme_bw(base_size = 16) +
  theme(legend.position = c(0.1, 0.85), legend.title=element_blank(),
        legend.background = element_rect(fill=alpha('white', 0)))
ggsave(paste0("Figure 1",".eps"), width = 6, height = 5)

legendOfC = c("C00","CM0","CME","CME")
legendOfNC = c("D00","D00","D00","DME")
titles = c("E2: Unconditional cooperation","E3: Direct reciprocity",
           "E4: Direct and indirect reciprocity","E5: No cognitive differences")
plist = list()
plist50k = list()
for(n in c(2,3,4,5)){

  p <- ggplot(Elist[[n]], aes(x = step, y = m, group = variable)) +
    ggtitle(titles[n-1]) +
    geom_line(aes(colour = factor(variable))) +
    geom_point(aes(colour = factor(variable)), size = 1) +
    geom_errorbar(position=position_dodge(width=20),
                  aes(ymin=m-s, ymax=m+s, colour = factor(variable)), width=100) +
    ylim(-2 , 50) + 
    labs(x = "ticks", y = "N") +
    scale_color_manual(values=c("blue", "red"), labels = c(legendOfC[n-1],legendOfNC[n-1])) +
    theme_bw(base_size = 12) +
    theme(legend.position = c(0.8, 0.85), legend.title=element_blank(), 
          legend.background = element_rect(fill=alpha('white', 0)),
          plot.title = element_text(size=12,hjust = 0.5))
  #ggsave(paste0("E",n,".eps"), width = 6, height = 5)
  plist[[n]] <- p
  
  p <- ggplot(Elist50k[[n]], aes(x = step, y = m, group = variable)) +
    ggtitle(titles[n-1]) +
    geom_line(aes(colour = factor(variable))) +
    geom_point(aes(colour = factor(variable)), size = 1) +
    geom_errorbar(position=position_dodge(width=20),
                  aes(ymin=m-s, ymax=m+s, colour = factor(variable)), width=2500) +
    ylim(-2 , 50) + 
    labs(x = "ticks", y = "N") +
    scale_color_manual(values=c("blue", "red"), labels = c(legendOfC[n-1],legendOfNC[n-1])) +
    theme_bw(base_size = 12) +
    theme(legend.position = c(0.8, 0.85), legend.title=element_blank(), 
          legend.background = element_rect(fill=alpha('white', 0)),
          plot.title = element_text(size=12,hjust = 0.5))
  plist50k[[n]] <- p
}

plot_grid(plist[[2]],plist[[3]],plist[[4]],plist[[5]],labels = "auto", scale =1, label_x
          =0, label_size = 14)
ggsave(paste0("Figure 2.eps"), width = 6, height = 5)

plot_grid(plist50k[[2]],plist50k[[3]],plist50k[[4]],plist50k[[5]],labels = "auto", scale =1, label_x
          =0, label_size = 14)
ggsave(paste0("Figure 3.eps"), width = 6, height = 5)

for(value in unique(E6$rr)){
  p <- ggplot(subset(E6means,E6means$rr == value), aes(x = C, y = Sca, group = experiment)) +
  geom_line(linetype="dotted") +
  geom_point(aes(shape = factor(experiment)), size = 3) +
  ylim(0 , 1) + 
  scale_x_continuous(breaks = c(10, 20, 30, 40 , 50, 60, 70, 80, 90)) +
  labs(x = expression(C[ini]), y = expression(bar("s"))) +
  scale_shape_discrete(labels = c("X00","CM0 vs D00","CME vs D00","XME")) +
  theme_bw(base_size = 16) +
  theme(legend.position = c(0.15, 0.8), legend.title=element_blank(),
        legend.background = element_rect(fill=alpha('white', 0)))
  ggsave(paste0("Figure ",value+3,".eps"), width = 6, height = 5)
}
