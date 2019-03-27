library(readr)
library(ggplot2)
require(dplyr)

#E1

E1 <- read_csv("E1-table.csv", skip = 6)
E1 <- E1[,-c(1,4,5,6)]
names(E1)[3] <- "a"

E1means <- summarise(group_by(E1, vr, C), 
                     ma = mean(a), sa = sd(a))

p <- ggplot(E1means, aes(x = vr, y = ma, group = C)) +
  geom_line(aes(colour = factor(C))) +
  geom_point(aes(colour = factor(C)), size = 3) +
  geom_errorbar(aes(ymin=ma-sa, ymax=ma+sa, colour = factor(C)), width=.05) +
  ylim(0 , 102) + 
  scale_x_continuous(breaks = c(1, 2, 3)) +
  labs(x = "RR", y = "N") +
  scale_color_manual(values=c("red", "blue"), labels = c("NC","C")) +
  theme_bw(base_size = 16) +
  theme(legend.position = c(0.1, 0.85), legend.title=element_blank())
ggsave(paste0("E1",".eps"), width = 6, height = 5)

#E2 , 3 , 4 , 5 

legendOfC = c("C0","CM","CML","CML")
legendOfNC = c("NC0","NC0","NC0","NCML")
for(n in c(2,3,4,5)){

  En <- read_csv(paste0("E",n,"-table.csv"), skip = 6)
  En <- En[,-c(1:5)]
  names(En) <- c("step","ca","nca", "t")
  
  En <- reshape2::melt(En, id.vars="step")
  
  Enmeans <- summarise(group_by(En, step, variable), 
                       m = mean(value), s = sd(value))
  Enmeans$step <- Enmeans$step + 1 
  Enmeans <- subset(Enmeans, step %in% c(1,200,400,600,800,1000,1200,1400,1600,1800,2000))
  
  p <- ggplot(Enmeans, aes(x = step, y = m, group = variable)) +
    geom_line(aes(colour = factor(variable))) +
    geom_point(aes(colour = factor(variable)), size = 3) +
    geom_errorbar(position=position_dodge(width=20), aes(ymin=m-s, ymax=m+s, colour = factor(variable)), width=100) +
    ylim(0 , 50) + 
    labs(x = "tick", y = "N") +
    scale_color_manual(values=c("blue", "red", "green"), labels = c(legendOfC[n-1],legendOfNC[n-1],"T")) +
    theme_bw(base_size = 16) +
    theme(legend.position = c(0.9, 0.85), legend.title=element_blank())
  ggsave(paste0("E",n,".eps"), width = 6, height = 5)

}

#6

E6VR1 <- read_csv("E6RR1-table.csv", skip = 6)
E6VR2 <- read_csv("E6RR2-table.csv", skip = 6)
E6VR3 <- read_csv("E6RR3-table.csv", skip = 6)

E6 <- rbind(E6VR1,E6VR2,E6VR3)
E6 <- E6[,-c(1,4,6)]
names(E6)[4:5] <- c("ca","a")
E6$nca <- E6$a - E6$ca

E6means <- summarise(group_by(E6, vr, experiment, C), 
                     Sca = mean(ca / a), Snca = mean(nca / a))

for(value in unique(E6$vr)){
  p <- ggplot(subset(E6means,E6means$vr == value), aes(x = C, y = Sca, group = experiment)) +
  geom_line(linetype="dotted") +
  geom_point(aes(shape = factor(experiment)), size = 3) +
  ylim(0 , 1) + 
  scale_x_continuous(breaks = c(10, 20, 30, 40 , 50, 60, 70, 80, 90)) +
  labs(x = expression(C[ini]), y = expression(bar("s"))) +
  scale_shape_discrete(labels = c("X0","CM vs NC0","CML vs NC0","XML")) +
  theme_bw(base_size = 16) +
  theme(legend.position = c(0.15, 0.8), legend.title=element_blank())
  ggsave(paste0("E6RR",value,".eps"), width = 6, height = 5)
}