#include "Riostream.h"
void convert_train_to_ROOT() {
//  Read data from an ascii file and create a root file with an histogram and an ntuple.
//	Author: Rozmin Daya, based on an example created by Rene Brun
      
   TString filename="DATA_FILE";
   printf("Using file: %s\n",filename.Data());

   ifstream in;
   in.open(Form(filename.Data()));
   
   Float_t FEATURE_NAMES_COMMA;

   Int_t nlines = 0;
   TFile *f = new TFile("ROOT_FILE","RECREATE");
   TTree *tree = new TTree("TREE_NAME","data from csv file");
   
   BRANCH_BLOCK

   while (1) {
      in>>FEATURE_NAMES_IN;
      if (!in.good()) break;
      tree->Fill();
      nlines++;
   }
   printf(" found %d points\n",nlines);

   in.close();

   f->Write();
}
