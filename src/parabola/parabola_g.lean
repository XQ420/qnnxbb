import Mathlib.Data.Real.Basic
import Mathlib.Tactic

theorem parabola_g (x₁ x₂ : ℝ)
                   (h₁ : g₁ = x₂ - x₁^2 - 1)
                   (h₂ : I = (3*x₁^2)/5 - (3*x₂)/5 + 3/10)
                   : 0 ≤ g₁ → 0 ≤ -I := by
  let δ₀ : ℝ := 3/10
  let δ₁ : ℝ := 3/5
  have I₁ : -I = δ₀ + δ₁*g₁ := by
    simp [h₁, h₂]
    linear_combination
  rw [I₁]
  intro g
  linarith
