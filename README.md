# KeplerOrbitSimulator2D
A 2-Dimmensional Kepler orbit simulator that allows uses to input orbital state vectors and relevant constants that define an orbit about a central fixed body, neglecting the mass of the satellite

KeplerOrbitSimulator2D Performs simulates the orbit under the following schema:  

* calculates elements of a kepler orbit including eccentricity, true anomaly, etc.
* constructs a kepler orbit as a polar function of the true anomaly
* uses newton's method to extrapolate for the eccentric anomaly as a function of time
* extrapolates the next true anomaly from this information
* plots the position of the satellite using the polar function defining the radius vector from the fixed body to the satellite

## User Manual

### Setting Up a User Defined Orbit:
1. stop the simulation by clicking/tapping the start/stop button  
2. set the recalculate option to true by clicking/tapping the recalculate button  
3. adjust the parameters using the 1d sliders for constants and/or scalars or the 2d sliders for state vectors
4. set recalculate to false (this is not necessary but recommended)  
5. set start/stop to true to run the simulation

### Adujusting run-time values (time step and radii):
1. Simply drag the sliders for these values left or right to alter their values; changes will take effect immediately

### Notes:
* Buttons are in the true state when light blue is towards the left  
* Under the hood, the y axis and positive angular direction are inverted

![Screenshot](https://github.com/MeadeRobert/OrbitSimulator/blob/master/screenshots/Screenshot%20from%202017-03-06%2019:00:45.png)  

## Javadoc  
[rjm27trekkie.chickenkiller.com/OrbitSimulator/doc](rjm27trekkie.chickenkiller.com/OrbitSimulator/doc)


