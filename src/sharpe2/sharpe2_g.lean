import Mathlib.Data.Real.Basic
import Mathlib.Tactic

theorem sharpe2_g (x₁ x₂ : ℝ)
                  (h₁ : g₁ = x₂ - x₁)
                  (h₂ : g₂ = x₁ + x₂)
                  (h₃ : I = -(2*x₂)/5 - x₁^2/5) :
                  0 < g₁ → 0 < g₂ → 0 ≤ -I := by
  let p₀ : ℝ := x₁/5
  let δ₀ : ℝ := 5*p₀^2
  let δ₁ : ℝ := 1/5
  let δ₂ : ℝ := 1/5
  have I₁ : -I = δ₀ + δ₁ * g₁ + δ₂ * g₂ := by
    simp [h₁, h₂, h₃]
    linear_combination
  intro g1 g2
  rw [I₁]
  have h1 : 0 ≤ δ₀ := by
    simp
    rw [←div_pow]
    have : 0 ≤ (x₁/5)^2 := by apply pow_two_nonneg
    linarith
  have h2 : 0 ≤ δ₁ * g₁ := by simp; rw [inv_eq_one_div]; linarith
  have h3 : 0 ≤ δ₂ * g₂ := by simp; rw [inv_eq_one_div]; linarith
  linarith
