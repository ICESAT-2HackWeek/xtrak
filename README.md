# xtrak
Fine-scale spatiotemporal interpolation between ICESat-2 tracks

## Collaborators

**Project Lead:** Tim Bartholomaus, _University of Idaho_

**Data Science Lead:** Fernando Paolo, _NASA Jet Propulsion Laboratory_

Lavanya Ashokkumar, _University of Arizona_

Taryn Black, _University of Washington_

Allison Chartrand, _Ohio State University_

Jukes Liu, _University of Maine_

Evan Carnahan, _University of Texas_

## The Problem
**How well can we interpolate between ICESat-2 tracks?**

ICESat-2 products will eventually include quarterly (91-day) gridded land ice elevations. We want to be able to also estimate elevations effectively continuously through time, so that we can get rough elevation profiles on shorter time scales. We will interpolate elevations between neighboring tracks to create gridded elevation data from which we can extract our elevation profiles. We do not expect the shape of an elevation profile to change significantly between the collection of neighboring tracks, so interpolating between them should be safe.

Pie-in-the-sky goal: essentially continuously updating elevation profiles, such that we can enter a location and date and get an estimated elevation profile.

## Application Example
**Interpolate ICESat-2 tracks to build elevation profiles of Zachariae Isstrom, an outlet glacier in northeastern Greenland.**

Most tracks over Greenland outlet glaciers are across-flow rather than along-flow, so it is hard to get a single temporally-consistent elevation profile of a glacier. By interpolating between neighboring tracks, we can build an along-flow elevation profiles of Zachariae Isstrom roughly every two weeks.

## Sample Data
* Operation IceBridge, ATM profiles over Zachariae Isstrom, 2014 & 2018
 `size, format, access?`
* ICESat-2 tracks over Zachariae Isstrom

## Specific Questions
* Can we reasonably estimate elevation `z(x,y,t)` for any arbitrary space `(x,y)` and time `(t)`?

## Existing Methods
* Airborne and satellite altimetry (_e.g._ Operation IceBridge ATM)

## Proposed Methods/Tools
* pandas, geopandas
* linear interpolation with scipy.griddata

# Workflow

### Get data

| script | input data | output data | notes |
| ------ | ---------- | ----------- | ----- |
| data_raw/downloadData.sh | NSIDC | data_raw/ATL06evan | _over ZI, all dates_ |
| manual download | NSIDC | data_raw/ATM_20** | |
| manual download | NSIDC | data_raw/ATL06lavanya | _over ZI, December only_ |

### Subset and extract variables of interest
| script | input data | output data | notes |
| ------ | ---------- | ----------- | ----- |
| IS2ZachExtract.ipynb | data_raw/ATL06evan | data_prod/ICESat2ZachData.csv | |
| ATMprocessing.ipynb | data-raw/ATM_20** | data_prod/ATMprof_20**\_slopes.csv | |

### Error checks, smoothing, and filtering
| script | input data | output data | notes |
| ------ | ---------- | ----------- | ----- |
| CheckForBadISatTransects.ipynb | data_prod/IceSat2ZachData.csv | data_prod/ZachISatData_wSmooth.csv | |
| SmoothAtm.ipynb | data_prod/ATMprof_20**\_slopes.csv | data_prod/ATMprof_20**\slopes_wSmooth.csv | |

### Identify crossover points
| script | input data | output data | notes |
| ------ | ---------- | ----------- | ----- |
| Intersections.ipynb | data_prod/ZachISatData_wSmooth.csv, ATMprof_20**\_slopes_wSmooth.csv | data_prod/InterX_ATM20**\_AllSmooth.csv | |

### Get residuals
| script | input data | output data | notes |
| ------ | ---------- | ----------- | ----- |
| calculate_residuals.ipynb | data_prod/InterX_ATM2014_AllSmooth.csv | data_prod/residuals.csv | |

### Interpolation
| script | input data | output data | notes |
| ------ | ---------- | ----------- | ----- |
| fit_residuals.ipynb | data_prod/residuals.csv | _plots_ | |
