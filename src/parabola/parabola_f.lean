import Mathlib.Data.Real.Basic
import Mathlib.Tactic


theorem parabola_f (x₁ x₂ : ℝ)
                   (h₁ : f₁ = x₁^2 - x₂)
                   (h₂ : I = (3*x₁^2)/5 - (3*x₂)/5 + 3/10)
                   : 0 ≤ f₁ → I > 0 := by
  let σ₀ : ℝ := 3/10-1/10000
  let σ₁ : ℝ := 3/5
  let ε : ℝ := 1/10000
  have I₁ : I = σ₀ + σ₁*f₁ + ε := by
    simp [h₂, h₁]
    linear_combination
  intro h1
  rw [I₁]
  linarith
