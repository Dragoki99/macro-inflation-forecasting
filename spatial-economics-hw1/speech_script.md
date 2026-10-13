# Speech script: Resolving the Amenity Puzzle (14 slides, about 13–15 minutes)

Suggested split (change as you like): **Davide** slides 1–3, **Caterina** slides 4–6, **Federica** slides 7–9, **Lorenzo** slides 10–14. Each speaker should be able to answer on every slide.

---

## Slide 1: Title (Davide)

Good morning, Professor. We are Davide, Caterina, Federica and Lorenzo, and today we present Homework 1, which we called "Resolving the Amenity Puzzle".

The story has three steps. In Part A we diagnose a puzzle in the Rosen–Roback model without land. In Part B we show that adding land and rents resolves it. In Part C we add agglomeration spillovers and ask what the data can and cannot identify.

---

## Slide 2: Recovered amenities do not attract people (Davide)

Let me start with the puzzle. We ran the script exactly as it was. The top-right panel plots log population against recovered log amenities. The OLS slope is +0.19, with an R-squared of 0.005. So the cloud is essentially flat.

Why is this surprising? Utility is U equals w times B, so people value amenities. If we multiply the two inversion formulas, we get A-hat times B-hat equal to W times L to the gamma. This means that, at the same recovered productivity, a location with 1% higher amenities must be 1 over gamma, that is 3.33%, larger. So we should see an upward slope.

Where does the flat line come from? Since B-hat equals W over w, the slope of the panel is minus the covariance of log L and log w, divided by the variance of log w. In the original script, L and w are drawn independently, so the covariance is zero and the slope is zero by construction. The 0.19 is just sampling noise: in this draw the correlation between log L and log w is minus 0.07.

---

## Slide 3: When wages are the only price, big cities look bad (Davide)

So the problem is in the data-generating block. The assumption that L and w are independent contradicts Fact 4 of Topic 1, the urban wage premium: denser places pay more, as Autor documents. So we replaced the wage draw with log w equals phi times log L plus noise, and we chose phi equal to 0.08, in line with the elasticities in Autor's figure.

Before running the script, we made a prediction. Since log B-hat is a constant minus log w, we get log B-hat equal to a constant minus phi log L minus noise. The derivative with respect to log L is minus phi, which is negative. So we predicted a negative slope.

And indeed the run gives minus 4.71. The model without land reads the high wages of big cities as compensation for bad amenities, so it concludes that large cities are the least pleasant places to live. The model, as a measurement device, mistakes an expensive city for an unpleasant one.

---

## Slide 4: Not a fluke, 5,000 Monte Carlo draws (Caterina)

To check that this is not an artifact of one draw, we repeated both data-generating blocks 5,000 times. With the original block, the slope is centred on zero, so the flat panel was the typical outcome. With the corrected block, the whole distribution lies below zero, with a mean of minus 2.73. This is close to the analytical value, which we will see in a moment, about minus 2.9.

So the negative panel is not a fluke. It is a structural implication of the urban wage premium in a model where the wage is the only price.

---

## Slide 5: Amenity spillovers cannot rescue the panel (Caterina)

Point (c). Suppose amenities have a spillover: B equals b times L to the eta, where b is exogenous.

First, would the panel with total recovered B change? No. The mobility condition involves only total amenities, and the inversion B equals W over w uses only observed wages. Eta never enters. So the panel is identical to the one in point (b).

Second, what about the panel built with the exogenous part, b-hat equal to B-hat times L to the minus eta? Taking logs, log b-hat is log B-hat minus eta log L, so the derivative with respect to log L is minus phi plus eta, with a minus sign in front: minus (phi plus eta). With positive spillovers the exogenous amenities fall even faster with size. The correlation goes from minus 0.66 to minus 0.98 as eta rises to 0.5.

One clarification: the derivative gives the sign of the panel. The fitted line of log L on log b actually gets flatter, because log L is on the vertical axis. And the panel would turn positive only with congestion stronger than the wage premium, eta below minus phi.

So spillovers do not solve the puzzle.

---

## Slide 6: Noise attenuates the slope toward zero (Caterina)

The bonus, point (d). The OLS slope is minus the covariance of log L and log w over the variance of log w.

With zero noise, log w is exactly phi times log L, so all points lie on one line, and the slope is exactly minus 1 over phi, that is minus 12.5. Our script confirms minus 12.50.

When we switch the noise back on, the slope moves toward zero. Why? The noise sits in the regressor, because log B-hat is c minus log w. It spreads the points horizontally, but it is unrelated to L. So the covariance does not change, while the variance of the regressor increases. The slope is therefore minus 1 over phi, times a reliability ratio lambda of about 0.23. That gives about minus 2.9, and minus 2.73 in the Monte Carlo. This is classical attenuation. And if the noise grows without bound, the slope goes to zero, which is exactly the flat panel of point (a).

---

## Slide 7: Adding land turns the panel positive (Federica)

Now Part B. With land, utility becomes U equals w times B over r to the power one minus mu, where one minus mu is the housing expenditure share. Rents come from housing-market clearing: r equals one minus mu, times w times L, over H.

We run the same corrected data through the new model. The population–amenities slope becomes plus 3.87 in this draw, against minus 4.71 without land. Over 5,000 Monte Carlo draws, the mean is plus 3.40, and it is positive in every single draw.

Notice also the wages–amenities panel. Without land it was exactly minus 1 by construction. Now it is a cloud, with slope close to zero, because amenities are read from rents and wages together, not from wages alone.

---

## Slide 8: Two channels, one threshold (Federica)

Points (b), (c) and (d). Why does the sign flip? Using the rent equation, B-hat is proportional to r to the one minus mu over w, which is proportional to w to the minus mu, times L to the one minus mu. In logs, with log w equal to phi log L plus noise, we get log B-hat equal to a constant plus the bracket (one minus mu) minus mu phi, times log L.

City size enters through two channels with opposite signs. The rent channel is plus one minus mu, that is 0.30: with fixed land, bigger cities have higher rents, and if people stay anyway, the model reads high amenities. The wage channel is minus mu phi, that is minus 0.056: this is the only channel we had in Part A. The net effect is plus 0.244.

For point (c), call the bracket d. The OLS slope is d times the variance of log L, over d squared times that variance plus mu squared sigma squared. The denominator is always positive, so the slope is positive if and only if d is positive. That means phi below one minus mu over mu, which is 0.43 for mu equal to 0.7. Realistic wage premia, between 0.02 and 0.08, are far below the threshold.

For point (d), we raised phi in the script and averaged 2,000 draws for each value. The simulated slope matches the formula in every row. It stays positive up to 0.40, it is exactly zero at 0.4286, and it turns negative afterwards. The curve is not monotonic: near the threshold the recovered amenities are almost pure noise.

---

## Slide 9: Land reconciles the model with Topic 1 (Federica)

Point (e). Which facts of Topic 1 does the model with land match at the same time? First, the urban wage premium: the correlation between log L and log w is about 0.50. Second, the urban rent premium: with fixed land, rents rise with population, and the correlation is about 0.99. Third, big cities can be desirable: the amenity slope is about plus 3.45. The model without land could match the wage premium only by making big cities look unpleasant, and it had no rent at all. Land is also the dispersion force that keeps city sizes finite.

We also want to be honest about the limits. With fixed land and Cobb–Douglas preferences, the elasticity of rents to size is about 1 plus phi, that is 1.08, far above the 0.16 to 0.20 of Topic 1, where housing supply partly adjusts. And the model has no trade costs and no worker sorting.

---

## Slide 10: Agglomeration versus dispersion, the sign of theta (Lorenzo)

Part C. Now productivity and amenities depend on size: A equals A-bar times L to the lambda, and B equals B-bar times L to the eta. Wages, rents and utility become powers of L, and the mobility condition becomes: A-bar to the mu, times B-bar, times H over one minus mu to the one minus mu, times L to the theta, equals W.

Theta is the net elasticity: eta plus mu lambda, minus the bracket one minus mu plus mu gamma. The first term collects agglomeration forces: the amenity spillover, and the productivity spillover weighted by mu. The second collects dispersion forces: housing congestion, and decreasing returns to labour, weighted by mu.

We call G the composite of the exogenous fundamentals: productivity, amenities and housing. Utility is then G times L to the theta, so population is G over W to the power one over absolute theta, and the shares have a closed form.

When theta is negative, utility falls with size. So exactly one W clears the market: the equilibrium is unique and stable. As theta goes to zero from below, the exponent one over absolute theta explodes, and the best location takes everything: in our runs the largest share goes from 4.8% to 53%. With theta positive the interior equilibrium is unstable, and outcomes depend on history. In our calibration, theta is minus 0.311.

---

## Slide 11: Same data, different spillovers, identical fit (Lorenzo)

Point (c). From the data on L, w and r, with gamma and mu known, we recover A, H and B exactly, without any assumption on lambda and eta. These are the composites.

But the exogenous parts, A-bar and B-bar, exist only for given lambda and eta. Any pair with negative theta reproduces the data exactly: when we re-solve the model, the gap is below ten to the minus fourteen. So "large spillovers and modest fundamentals" fits as well as "no spillovers and large fundamentals". In the figure, only the true pair lies on the 45-degree line.

What would pin them down? Exogenous variation in the fundamentals, such as natural experiments like the division and reunification of Berlin in Topic 7.

---

## Slide 12: A plus 20% productivity boom in one location (Lorenzo)

Point (d). We raise A-bar in location 46 by 20%. Differentiating the mobility condition, the population response is mu times one minus pi-j, over absolute theta. So, to first order, it is scaled by one over absolute theta. Without spillovers, absolute theta is 0.51. With spillovers it is 0.311. The ratio is about 1.64.

Numerically, the population of location 46 rises by 49.7% instead of 27.9%. The first-order approximation underestimates, because a 20% shock is not infinitesimal. The local wage rises 9.4%, the local rent 63.7%, and common welfare 0.215%. All other locations lose about 0.7% of their population.

---

## Slide 13: Same theta, different policy answers (Lorenzo)

Point (e). Population shares depend on lambda, eta and mu only through theta, and eta and one minus mu enter with opposite signs. So a large amenity spillover can look identical to a low housing share. In our calibration, the pair (0.07, 0.15) and the pair (0, 0.199) have the same theta and the same population response. The heat map shows the response is constant along iso-theta lines.

An observable that separates them is the housing expenditure share from household budget surveys, which equals one minus mu. A policy whose answer depends on it is upzoning, an increase in the housing stock. The population response is one minus mu, times one minus pi-j, over absolute theta, times the change in housing. So for the same theta, the gains are large if theta is small because of a big amenity spillover with a high housing share, and small if housing matters little.

There is also a normative point: if eta is positive, amenity spillovers are a positive externality, cities are too small, and place-based policy can improve welfare. If eta is zero, the efficient benchmark applies, and the same policies only create distortions.

---

## Slide 14: Takeaways (Davide or whoever closes)

To conclude, three messages.

One: wages alone mislead. When the wage is the only price, the urban wage premium is read as bad amenities, and big cities look unpleasant.

Two: rents resolve the puzzle. With land, rents absorb high wages, and the panel turns positive whenever phi is below one minus mu over mu, about 0.43.

Three: cross-sections identify theta, not its parts. Separating spillovers from the housing share needs extra information, such as expenditure shares or natural experiments, and policy answers depend on it.

Thank you for your attention. We are happy to take questions.

---

## Quick answers for likely questions

- **Why does B-hat not depend on eta?** The inversion uses only observed L and w. Spillovers change how we decompose B, not its total value.
- **Why does the slope get flatter with noise?** Noise adds variance to the regressor log B-hat but no covariance with log L: attenuation.
- **Why is the first-order ratio 1.64 and the exact one about 1.78?** The shock is 20%, not infinitesimal, and the first-order formula ignores the curvature.
- **Where do the numbers in Part B come from?** From the script RR2 with phi equal to 0.08, mu equal to 0.7, gamma equal to 0.3, sigma equal to 0.15. Single draw and 5,000 Monte Carlo draws.
- **What if theta is positive?** The interior equilibrium is unstable: core–periphery outcomes and path dependence.
- **How did you choose phi?** From the slope of the fitted lines in Autor's figure (Topic 1, slide 22): about 0.07–0.08 for college workers.
