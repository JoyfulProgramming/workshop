Rails.application.routes.draw do
  mount SolidErrors::Engine, at: "/solid_errors"
  mount MissionControl::Jobs::Engine, at: "/jobs"

  resources :patterns, only: [ :new, :create, :show, :edit, :update ] do
    member do
      get :update_progress
      get :download
      get :download_pdf
    end
  end
  root "patterns#new"
end
