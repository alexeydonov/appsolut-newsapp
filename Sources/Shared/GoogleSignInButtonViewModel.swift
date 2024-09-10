//
//  GoogleSignInButtonViewModel.swift
//  NewsApp
//
//  Created by Alexey Donov on 07.09.2024.
//

import GoogleSignInSwift

extension GoogleSignInButtonViewModel {
    static var customized: GoogleSignInButtonViewModel {
        GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)
    }
}
