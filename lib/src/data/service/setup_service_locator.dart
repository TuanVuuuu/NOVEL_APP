import 'package:audiobook/admin/cubit/auto_get_data_cubit.dart';
import 'package:audiobook/src/data/service/local/local_service_api.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:audiobook/src/data/source/business/service_repository_impl.dart';
import 'package:audiobook/src/data/source/local/local_service_repository.dart';
import 'package:audiobook/src/data/source/local/local_service_repository_impl.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
import 'package:audiobook/view/home_page/cubit/home_page_cubit.dart';
import 'package:audiobook/view/novel_info/cubit/novel_info_cubit.dart';
import 'package:audiobook/view/search_page/cubit/search_page_cubit.dart';
import 'package:get/get.dart';

import 'business/service_api.dart';

void setupServiceLocator() {
  Get
    ..put<ServiceRepository>(
        ServiceStorageRepository(
          api: ServiceApi(),
        ),
        permanent: true)
    ..put<LocalServiceRepository>(
        LocalServiceStorageRepository(
          api: LocalServiceApi(),
        ),
        permanent: true)
    ..put(HomePageCubit(Get.find()))
    ..put(NovelInfoCubit(Get.find()))
    ..put(SearchPageCubit(Get.find()))
    ..put(AutoGetDataCubit(Get.find()))
    ..put(ChapterDetailCubit(Get.find()));
}
