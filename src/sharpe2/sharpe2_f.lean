import Mathlib.Data.Real.Basic
import Mathlib.Tactic

theorem sharpe2_f (x₁ x₂ : ℝ)
                  (h₁ : f₁ = -x₁^2 - x₂)
                  (h₂ : I = -(2*x₂)/5 - x₁^2/5) :
                  0 ≤ f₁ → 0 ≤ I := by
  let p₀ : ℝ := x₁/5
  let σ₀ : ℝ := 5*p₀^2
  let σ₁ : ℝ := 2/5
  have I₁ : I = σ₀ + σ₁ * f₁ + 0 := by
    simp [h₁, h₂]
    linear_combination
  intro f
  rw [I₁]
  have h1 : 0 ≤ σ₀ := by
    simp
    rw [←div_pow]
    have : 0 ≤ (x₁/5)^2 := by apply pow_two_nonneg
    linarith
  have h2 : 0 ≤ σ₁*f₁ := by simp; linarith
  linarith
