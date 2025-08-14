terraform {
  cloud {

    organization = "Nombre de la organización"

    workspaces {
      name = "espacio de trabajo asociado"
    }
  }
}