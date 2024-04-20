import Mathlib.Data.Real.Basic
import Mathlib.Tactic

theorem sharpe1_f (x₁ x₂ : ℝ)
                  (h₁ : f₁ = 1 - x₁^2 - x₂^2)
                  (h₂ : I = (6*x₂)/5 - x₁^2/10 + 6/5) :
                  0 ≤ f₁ → 0 ≤ I := by
  let p₀ : ℝ := (3*x₂)/5 + 3/5
  let p₁ : ℝ := 0
  let p₂ : ℝ := x₁/2
  let σ₀ : ℝ := 5/3*p₀^2 + 0*p₁^2 + 2*p₂^2
  let σ₁ : ℝ := 3/5
  have I₁ : I = σ₀ + σ₁*f₁ + 0 := by
    simp [h₁,h₂]
    linear_combination
  have h1 : 0 ≤ σ₀ := by
    have : 0 ≤ (5:ℝ) / 3 * (3 * x₂ / 5 + 3 / 5) ^ 2 := by
      have : 0 ≤ (3 * x₂ / 5 + 3 / 5) ^ 2 := by apply pow_two_nonneg (3 * x₂ / 5 + 3 / 5)
      linarith
    have : 0 ≤ (2:ℝ) * (x₁ ^ 2 / 2 ^ 2) := by
      rw [←div_pow]
      have :0 ≤ (x₁/2)^2 := by apply pow_two_nonneg (x₁/2)
      linarith
    simp
    linarith
  intro f
  have h2 : 0 ≤ σ₁*f₁ := by simp; linarith
  rw [I₁]
  rw [add_zero]
  linarith
