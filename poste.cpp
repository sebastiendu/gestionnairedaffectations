#include "poste.h"
#include <string>
#include <QPainter>

Poste::Poste()
{
}

// Dessin du marqueur

// === GETTERS SETTERS ====

string Poste::getNom(){
    return this->nom;
}

string Poste::getDescription(){
    return this->description;
}

int Poste::getX(){
    return this->x;
}

int Poste::getY(){
    return this->y;
}

void Poste::setDescription(string d){
    this->description = d;
}

void Poste::setNom(string n){
    this->nom = n;
}

void Poste::setPosition(int newX,int newY)
{
    this->x = newX;
    this->y = newY;
}

