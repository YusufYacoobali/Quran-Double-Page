class Bookmark {
  final int pageNumber;
  final String surah;

  Bookmark({required this.pageNumber}) : surah = _getSurahName(pageNumber);

  static String _getSurahName(int pageNumber) {
    if (pageNumber >= 0 && pageNumber <= 3) return "Start";
    if (pageNumber == 4) return "Al-Fatiha";
    if (pageNumber >= 5 && pageNumber <= 69) return "Al-Baqarah";
    if (pageNumber >= 70 && pageNumber <= 107) return "Aal-E-Imran";
    if (pageNumber >= 108 && pageNumber <= 148) return "An-Nisa";
    if (pageNumber >= 149 && pageNumber <= 178) return "Al-Maidah";
    if (pageNumber >= 179 && pageNumber <= 210) return "Al-Anam";
    if (pageNumber >= 211 && pageNumber <= 247) return "Al-Araf";
    if (pageNumber >= 248 && pageNumber <= 261) return "Al-Anfal";
    if (pageNumber >= 261 && pageNumber <= 289) return "At-Tawbah";
    if (pageNumber >= 290 && pageNumber <= 309) return "Yunus";
    if (pageNumber >= 310 && pageNumber <= 329) return "Hud";
    if (pageNumber >= 330 && pageNumber <= 347) return "Yusuf";
    if (pageNumber >= 348 && pageNumber <= 356) return "Ar-Rad";
    if (pageNumber >= 357 && pageNumber <= 365) return "Ibrahim";
    if (pageNumber >= 366 && pageNumber <= 373) return "Al-Hijr";
    if (pageNumber >= 374 && pageNumber <= 394) return "An-Nahl";
    if (pageNumber >= 395 && pageNumber <= 409) return "Al-Isra";
    if (pageNumber >= 410 && pageNumber <= 426) return "Al-Kahf";
    if (pageNumber >= 427 && pageNumber <= 436) return "Maryam";
    if (pageNumber >= 437 && pageNumber <= 450) return "Taha";
    if (pageNumber >= 451 && pageNumber <= 463) return "Al-Anbiya";
    if (pageNumber >= 464 && pageNumber <= 478) return "Al-Hajj";
    if (pageNumber >= 479 && pageNumber <= 488) return "Al-Muminun";
    if (pageNumber >= 489 && pageNumber <= 502) return "An-Nur";
    if (pageNumber >= 503 && pageNumber <= 512) return "Al-Furqan";
    if (pageNumber >= 513 && pageNumber <= 526) return "Ash-Shuara";
    if (pageNumber >= 527 && pageNumber <= 538) return "An-Naml";
    if (pageNumber >= 539 && pageNumber <= 553) return "Al-Qasas";
    if (pageNumber >= 554 && pageNumber <= 563) return "Al-Ankabut";
    if (pageNumber >= 564 && pageNumber <= 572) return "Ar-Rum";
    if (pageNumber >= 573 && pageNumber <= 578) return "Luqman";
    if (pageNumber >= 579 && pageNumber <= 582) return "As-Sajda";
    if (pageNumber >= 583 && pageNumber <= 596) return "Al-Ahzab";
    if (pageNumber >= 597 && pageNumber <= 604) return "Saba";
    if (pageNumber >= 605 && pageNumber <= 612) return "Fatir";
    if (pageNumber >= 613 && pageNumber <= 619) return "Ya-Sin";
    if (pageNumber >= 620 && pageNumber <= 629) return "As-Saffat";
    if (pageNumber >= 630 && pageNumber <= 636) return "Sad";
    if (pageNumber >= 637 && pageNumber <= 648) return "Az-Zumar";
    if (pageNumber >= 649 && pageNumber <= 660) return "Mu'min";
    if (pageNumber >= 661 && pageNumber <= 669) return "Fussilat";
    if (pageNumber >= 670 && pageNumber <= 678) return "Ash-Shura";
    if (pageNumber >= 679 && pageNumber <= 687) return "Az-Zukhruf";
    if (pageNumber >= 688 && pageNumber <= 692) return "Ad-Dukhan";
    if (pageNumber >= 693 && pageNumber <= 698) return "Al-Jathiya";
    if (pageNumber >= 699 && pageNumber <= 705) return "Al-Ahqaf";
    if (pageNumber >= 706 && pageNumber <= 711) return "Muhammad";
    if (pageNumber >= 712 && pageNumber <= 717) return "Al-Fath";
    if (pageNumber >= 718 && pageNumber <= 722) return "Al-Hujurat";
    if (pageNumber >= 723 && pageNumber <= 726) return "Qaf";
    if (pageNumber >= 727 && pageNumber <= 730) return "Adh-Dhariyat";
    if (pageNumber >= 731 && pageNumber <= 733) return "At-Tur";
    if (pageNumber >= 734 && pageNumber <= 737) return "An-Najm";
    if (pageNumber >= 738 && pageNumber <= 741) return "Al-Qamar";
    if (pageNumber >= 742 && pageNumber <= 746) return "Ar-Rahman";
    if (pageNumber >= 747 && pageNumber <= 751) return "Al-Waqia";
    if (pageNumber >= 752 && pageNumber <= 758) return "Al-Hadid";
    if (pageNumber >= 759 && pageNumber <= 762) return "Al-Mujadila";
    if (pageNumber >= 763 && pageNumber <= 767) return "Al-Hashr";
    if (pageNumber >= 768 && pageNumber <= 771) return "Al-Mumtahina";
    if (pageNumber >= 772 && pageNumber <= 774) return "As-Saff";
    if (pageNumber >= 775 && pageNumber <= 776) return "Al-Jumuah";
    if (pageNumber >= 777 && pageNumber <= 778) return "Al-Munafiqun";
    if (pageNumber >= 779 && pageNumber <= 781) return "At-Taghabun";
    if (pageNumber >= 782 && pageNumber <= 784) return "At-Talaq";
    if (pageNumber >= 785 && pageNumber <= 788) return "At-Tahrim";
    if (pageNumber >= 789 && pageNumber <= 791) return "Al-Mulk";
    if (pageNumber >= 792 && pageNumber <= 795) return "Al-Qalam";
    if (pageNumber >= 796 && pageNumber <= 798) return "Al-Haaqqa";
    if (pageNumber >= 799 && pageNumber <= 801) return "Al-Maarij";
    if (pageNumber >= 802 && pageNumber <= 804) return "Nuh";
    if (pageNumber >= 805 && pageNumber <= 807) return "Al-Jinn";
    if (pageNumber >= 808 && pageNumber <= 809) return "Al-Muzzammil";
    if (pageNumber >= 810 && pageNumber <= 812) return "Al-Muddathir";
    if (pageNumber >= 813 && pageNumber <= 814) return "Al-Qiyama";
    if (pageNumber >= 815 && pageNumber <= 817) return "Al-Insan";
    if (pageNumber >= 818 && pageNumber <= 820) return "Al-Mursalat";
    if (pageNumber == 821) return "An-Naba";
    if (pageNumber >= 822 && pageNumber <= 823) return "An-Nazi'at";
    if (pageNumber >= 824 && pageNumber <= 825) return "Abasa";
    if (pageNumber == 826) return "At-Takwir";
    if (pageNumber == 827) return "Al-Infitar";
    if (pageNumber >= 828 && pageNumber <= 829) return "Al-Mutaffifin";
    if (pageNumber == 830) return "Al-Inshiqaq";
    if (pageNumber == 831) return "Al-Buruj";
    if (pageNumber == 832) return "At-Tariq";
    if (pageNumber == 833) return "Al-Ala";
    if (pageNumber == 834) return "Al-Ghashiya";
    if (pageNumber >= 835 && pageNumber <= 836) return "Al-Fajr";
    if (pageNumber == 837) return "Al-Balad";
    if (pageNumber == 838) return "Ash-Shams";
    if (pageNumber == 839) return "Al-Layl";
    if (pageNumber == 840) return "Adh-Dhuha";
    if (pageNumber == 841) return "At-Tin";
    if (pageNumber == 842) return "Al-Qadr";
    if (pageNumber == 843) return "Az-Zalzalah";
    if (pageNumber == 844) return "Al-Adiyat";
    if (pageNumber == 845) return "Al-Qaria";
    if (pageNumber == 846) return "Al-Asr";
    if (pageNumber == 847) return "Quraish";
    if (pageNumber == 848) return "Al-Kawthar";
    if (pageNumber == 849) return "Al-Masad";
    if (pageNumber == 850) return "An-Nas";
    if (pageNumber == 851) return "Dua";
    return "Surah";
  }
}



// in 0..3 -> "Start"
//         4 -> "Al-Fatiha"
//         in 5..69 -> "Al-Baqarah"
//         in 70..107 -> "Aal-E-Imran"
//         in 108..148 -> "An-Nisa"
//         in 149..178 -> "Al-Maidah"
//         in 179..210 -> "Al-Anam"
//         in 211..247 -> "Al-Araf"
//         in 248..261 -> "Al-Anfal"
//         in 261..289 -> "At-Tawbah"
//         in 290..309 -> "Yunus"
//         in 310..329 -> "Hud"
//         in 330..347 -> "Yusuf"
//         in 348..356 -> "Ar-Rad"
//         in 357..365 -> "Ibrahim"
//         in 366..373 -> "Al-Hijr"
//         in 374..394 -> "An-Nahl"
//         in 395..409 -> "Al-Isra"
//         in 410..426 -> "Al-Kahf"
//         in 427..436 -> "Maryam"
//         in 437..450 -> "Taha"
//         in 451..463 -> "Al-Anbiya"
//         in 464..478 -> "Al-Hajj"
//         in 479..488 -> "Al-Muminun"
//         in 489..502 -> "An-Nur"
//         in 503..512 -> "Al-Furqan"
//         in 513..526 -> "Ash-Shuara"
//         in 527..538 -> "An-Naml"
//         in 539..553 -> "Al-Qasas"
//         in 554..563 -> "Al-Ankabut"
//         in 564..572 -> "Ar-Rum"
//         in 573..578 -> "Luqman"
//         in 579..582 -> "As-Sajda"
//         in 583..596 -> "Al-Ahzab"
//         in 597..604 -> "Saba"
//         in 605..612 -> "Fatir"
//         in 613..619 -> "Ya-Sin"
//         in 620..629 -> "As-Saffat"
//         in 630..636 -> "Sad"
//         in 637..648 -> "Az-Zumar"
//         in 649..660 -> "Mu'min"
//         in 661..669 -> "Fussilat"
//         in 670..678 -> "Ash-Shura"
//         in 679..687 -> "Az-Zukhruf"
//         in 688..692 -> "Ad-Dukhan"
//         in 693..698 -> "Al-Jathiya"
//         in 699..705 -> "Al-Ahqaf"
//         in 706..711 -> "Muhammad"
//         in 712..717 -> "Al-Fath"
//         in 718..722 -> "Al-Hujurat"
//         in 723..726 -> "Qaf"
//         in 727..730 -> "Adh-Dhariyat"
//         in 731..733 -> "At-Tur"
//         in 734..737 -> "An-Najm"
//         in 738..741 -> "Al-Qamar"
//         in 742..746 -> "Ar-Rahman"
//         in 747..751 -> "Al-Waqia"
//         in 752..758 -> "Al-Hadid"
//         in 759..762 -> "Al-Mujadila"
//         in 763..767 -> "Al-Hashr"
//         in 768..771 -> "Al-Mumtahina"
//         in 772..774 -> "As-Saff"
//         in 775..776 -> "Al-Jumuah"
//         in 777..778 -> "Al-Munafiqun"
//         in 779..781 -> "At-Taghabun"
//         in 782..784 -> "At-Talaq"
//         in 785..788 -> "At-Tahrim"
//         in 789..791 -> "Al-Mulk"
//         in 792..795 -> "Al-Qalam"
//         in 796..798 -> "Al-Haaqqa"
//         in 799..801 -> "Al-Maarij"
//         in 802..804 -> "Nuh"
//         in 805..807 -> "Al-Jinn"
//         in 808..809 -> "Al-Muzzammil"
//         in 810..812 -> "Al-Muddathir"
//         in 813..814 -> "Al-Qiyama"
//         in 815..817 -> "Al-Insan"
//         in 818..820 -> "Al-Mursalat"
//         821 -> "An-Naba"
//         in 822..823 -> "An-Nazi'at"
//         in 824..825 -> "Abasa"
//         826 -> "At-Takwir"
//         827 -> "Al-Infitar"
//         in 828..829 -> "Al-Mutaffifin"
//         830 -> "Al-Inshiqaq"
//         831 -> "Al-Buruj"
//         832 -> "At-Tariq"
//         833 -> "Al-Ala"
//         834 -> "Al-Ghashiya"
//         in 835..836 -> "Al-Fajr"
//         837 -> "Al-Balad"
//         838 -> "Ash-Shams"
//         839 -> "Al-Layl"
//         840 -> "Adh-Dhuha"
//         841 -> "At-Tin"
//         842 -> "Al-Qadr"
//         843 -> "Az-Zalzalah"
//         844 -> "Al-Adiyat"
//         845 -> "Al-Qaria"
//         846 -> "Al-Asr"
//         847 -> "Quraish"
//         848 -> "Al-Kawthar"
//         849 -> "Al-Masad"
//         850 -> "An-Nas"
//         851 -> "Dua"
//         else -> "Surah"