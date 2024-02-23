import 'package:audiobook/admin/cubit/auto_get_data_cubit.dart';
import 'package:audiobook/src/data/service/local/local_service_api.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:audiobook/src/data/source/business/service_repository_impl.dart';
import 'package:audiobook/src/data/source/local/local_service_repository.dart';
import 'package:audiobook/src/data/source/local/local_service_repository_impl.dart';
import 'package:audiobook/view/home_page/cubit/home_page_cubit.dart';
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
    ..put(AutoGetDataCubit(Get.find()));
}
