import Mathlib.Data.Real.Basic
import Mathlib.Tactic

theorem sharpe1_g (x₁ x₂ : ℝ)
                  (h₁ : g₁ = -1 - x₂)
                  (h₂ : I = (6*x₂)/5 - x₁^2/10 + 6/5) :
                  0 < g₁ → 0 ≤ -I := by
  let p₀ : ℝ := x₁/10
  let δ₀ : ℝ := 10*p₀^2
  let δ₁ : ℝ := 6/5
  have I₁ :  -I = δ₀ + δ₁ * g₁ := by
    simp [h₁, h₂]
    linear_combination
  intro g
  rw [I₁]
  have h1 : 0 ≤ δ₀ := by
    simp
    rw [← div_pow]
    have :0 ≤ (x₁/10)^2 := by apply pow_two_nonneg (x₁/10)
    linarith
  have h2 : 0 ≤ δ₁*g₁ := by
    have : 0 ≤ g₁ := by linarith
    simp
    linarith
  linarith
