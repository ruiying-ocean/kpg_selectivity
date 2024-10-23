## create a solar constant forcing to be used in cGENIE
## this is to simulate the K-Pg impact winter
## 1st year: 0% solar constant
## 2nd year: 18% solar constant
## 3rd year: 87.5% solar constant
## 4th year: 100% solar constant
## all others: 100% solar constant
## time step: 1 year

## expect result:
# -START-OF-DATA-
# 0.5 1360.33
# 1.5 1360.33
# xxx xxxx
# -END-OF-DATA-

import numpy as np

time_span = np.arange(1, 1001, 1) - 0.5
## stop time: the 30th year
stop_yr = 30
preimpact_solar_constant = 1360.33

solar_constant = np.ones(len(time_span)) * preimpact_solar_constant
## modify the 10-14th year
solar_constant[10] = preimpact_solar_constant * 0.0
solar_constant[11] = preimpact_solar_constant * 0.18
solar_constant[12] = preimpact_solar_constant * 0.875

## write to file given the format
with open('/Users/yingrui/Science/kpg_ecosystem/data/solar_constant.txt', 'w') as f:
    f.write('-START-OF-DATA-\n')
    for i in range(len(time_span)):
        f.write('{:.1f} {:.2f}\n'.format(time_span[i], solar_constant[i]))
    f.write('-END-OF-DATA-\n')