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



# Further advanced triggering strategies to be studied and tested:

## A) EWMA (make signals persistent)

1. **EWMA of z-scores (n-aware; recommended)**

   * Build weekly (z_t=\dfrac{p_t-p_0}{\sqrt{p_0(1-p_0)/n_t}}) vs. an 8-week baseline (p_0).
   * Smooth: (\bar z_t=\lambda z_t+(1-\lambda)\bar z_{t-1}), with half-life (h) weeks and (\lambda=1-2^{-1/h}).
   * Alert: instant on big (z_t) (e.g., ≤−4 & Δpp≥1–2pp), persistent on (\bar z_t) (e.g., ≤−2.5).

2. **Variable-n EWMA p-chart (dynamic limits)**

   * Smooth raw (p_t); use n-aware limits
     (\sigma_t \approx \sqrt{\frac{p_0(1-p_0)}{n_t}\cdot\frac{\lambda}{2-\lambda}}).
   * Alert when (p_t - \text{EWMA}_{t-1} < -k\sigma_t) (k≈3).

3. **EWMA of standardized residuals**

   * Residual (r_t=p_t-\hat p_t^{\text{baseline}}); standardize by (\sqrt{\hat p(1-\hat p)/n_t}), then EWMA.

4. **Ratio of EWMAs (fails/tested)**

   * EWMA fails and tested separately, take (\tilde p_t=S^{ewma}/N^{ewma}). Simple, naturally down-weights low-n weeks.

5. **Discounted Beta–Binomial (Bayesian EWMA)**

   * Maintain Beta((\alpha,\beta)); discount prior by (\delta=2^{-1/h}):
     (\alpha_t=\delta\alpha_{t-1}+x_t,\ \beta_t=\delta\beta_{t-1}+(n_t-x_t)).
   * Use (\hat p_t=\alpha_t/(\alpha_t+\beta_t)) and credible bands for alerts.

6. **EWMA on Fisher evidence (great for small counts)**

   * One-sided Fisher p each week; score (s_t=-\log_{10}p_t); smooth ( \bar s_t ) with half-life (h).
   * Persistent alert when (\bar s_t \ge T) (tune T by backtesting).

## B) CUSUM (accumulate evidence)

7. **CUSUM on z (downward one-sided)**

   * (C_t=\max{0,\ C_{t-1}+(-z_t - k)}); alarm when (C_t\ge h).
   * Defaults: (k=0.5) (target ~1σ shifts), (h\approx4); backtest per product/site.

8. **Binomial LLR-CUSUM (small-n friendly)**

   * With baseline (p_0) and target shift (p_1=p_0+\delta):
     (\text{LLR}_t = x_t\ln\frac{p_1}{p_0} + (n_t-x_t)\ln\frac{1-p_1}{1-p_0}).
   * (C_t=\max{0, C_{t-1}+\text{LLR}_t}); alarm at (C_t\ge h).
   * Tune (\delta) (e.g., 0.5–1.0pp) and (h) via backtests.

## C) Deployment pattern (how to use them safely)

9. **Dual-lane logic (HVM-safe)**

   * **Instant lane:** if exposure is high (tested ≥ (N_{\text{hi}})), Δpp big (≥1–1.5pp), and p tiny (e.g., <1e−4) → **immediate OCAP**.
   * **Persistent lane:** otherwise require sustained evidence via **EWMA(z)**, **EWMA(−log p)**, or **CUSUM**.

10. **Guardrails & tuning**

* Volume gates: ignore weeks with tested < (N_{\min}).
* Clip extreme z (e.g., ±6).
* Pick half-life in **weeks** (common: (h=4 \Rightarrow \lambda\approx0.159)).
* Backtest per product/site to meet a false-alarm budget (e.g., ≤2/month/product).
