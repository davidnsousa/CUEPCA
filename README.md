# Cooperation under ecological pressure: Cognitive adaptations (CUEPCA)

This repositery contains all the material and intrunctions necessary to reproduce the CUEPCA's model results:

```
CUEPCA.nlogo
run.sh
results.R
```

In the netlogo main folder type

```
git clone https://github.com/davidnsousa/CUEPCA.git; cd CUEPCA
```

All experiments (E1 to E6) in the netlogo behavior space can be run with the bash script:

```
bash run.sh
```
The output is saved in the same folder. Use

```
Rscript results.R
```

to produce all plots.

IMPORTANT NOTES: We suggest that all experiments are run in a cluster. Please note the R dependencies in results.R.
