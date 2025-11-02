[![Makefile CI](https://github.com/shaoyinguo-portfolio/yield-triggers/actions/workflows/makefile.yml/badge.svg)](https://github.com/shaoyinguo-portfolio/yield-triggers/actions/workflows/makefile.yml)

# Proactive Yield Loss Drift Detection & Alerting with Adaptive Cadence Configuration

## Background
In high-volume manufacturing, automating **early yield loss drift** detection at different cadences (e.g., shiftly, daily, weekly) is crucial for triggering proper engineering attention for root cause analysis without overloading limited resources.

**Traditional Statistical Process Control (SPC)** methods like P-Charts and Cusum are effective for immediate, lot-level operator intervention. However, they are **poorly suited for engineering analysis** across mixed products with varying baselines, often requiring complex **stratification** and pre-determined trigger limits that miss subtle drifts in stable production with low defect counts.

**EWMA** introduces a smoothing factor ($\lambda$) to allow detection across longer spans, but it's difficult to correlate $\lambda$ with meaningful reporting cadences such as daily or weekly.

**ML methods** like **Isolation Forest** require tuning a fixed contamination parameter, undermining adaptability and risking forced alarms without guaranteeing statistical accuracy.

## Goal
The objective is to establish a **hyperparameter-free statistical framework** that is inherently **adaptive** to mixed-product baselines and seamlessly supports configurable reporting cadences. This approach must provide highly reliable, actionable triggers for engineers to distinguish abnormal yield fluctuations from normal process noise.

## ✅ The Proposed Framework: Adaptive Fisher's Exact Test

Inspired by variable control limits and $\chi^2$, where limits are adaptive to historical averages, this notebook demonstrates **Adaptive Fisher's Exact Test**. This method offers the optimal blend of **statistical rigor and low operational overhead** for engineered reporting:

* **Statistical Foundation**
    * **Benefit:** Provides the most accurate measure of significance via **Exact P-Value**, which is **valid regardless of low defect counts.**
    * **Conclusion:** **Eliminates Approximation Error** inherent in $\chi^2$ and P-Charts.

* **Adaptivity**
    * **Benefit:** Features **Inherent Sample Size Adaptivity** as the test's sensitivity automatically adjusts to the size of the current batch/week being compared to the baseline.
    * **Conclusion:** It is **Hyperparameter-Free**, requiring **minimal tuning** (no $\lambda$ or `contamination` inputs), which simplifies maintenance.

* **Actionability**
    * **Benefit:** Uses **Directional Logic** to combine P-value results with business rules (e.g., only flag increases) to ensure engineers only investigate statistically genuine **detrimental drifts**.
    * **Conclusion:** Represents the **Cleanest Solution**, focusing strictly on actionable, aggregated triggers for efficient investigation.
